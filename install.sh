#!/usr/bin/env bash

set -e

echo "=== Updating system ==="
sudo pacman -Syu --noconfirm

echo "=== Installing pacman packages ==="
if [[ -f packages/pacman.txt ]]; then
    sudo pacman -S --needed --noconfirm $(grep -vE '^\s*#|^\s*$' packages/pacman.txt)
fi

echo "=== Checking for yay ==="
if ! command -v yay &>/dev/null; then
    echo "Installing yay..."

    sudo pacman -S --needed --noconfirm git base-devel

    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"

    cd "$tmpdir/yay"
    makepkg -si --noconfirm

    cd -
    rm -rf "$tmpdir"
fi

echo "=== Installing AUR packages ==="
if [[ -f packages/aur.txt ]]; then
    yay -S --needed --noconfirm $(grep -vE '^\s*#|^\s*$' packages/aur.txt)
fi

echo "=== Checking for Flatpak ==="
if [[ -f packages/flatpak.txt ]]; then

    if ! command -v flatpak &>/dev/null; then
        sudo pacman -S --needed --noconfirm flatpak
    fi

    flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo

    while read -r package; do
        [[ -z "$package" || "$package" =~ ^# ]] && continue

        echo "Installing Flatpak: $package"
        flatpak install -y flathub "$package"
    done < packages/flatpak.txt
fi

echo
echo "=== Done! ==="
