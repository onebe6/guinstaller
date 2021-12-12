#!/bin/bash

sudo sed -i 's/%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL \n Defaults !tty_tickets/' /etc/sudoers

for PKG in $(cat PKGS_BASIC.txt); do
    echo "DOWNLOADING: $PKG"
    sudo pacman -S $PKG --noconfirm --needed
done

echo "exec i3" | cat > ~/.xinitrc

sudo systemctl enable lightdm.sevice
