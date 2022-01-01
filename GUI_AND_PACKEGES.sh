#!/bin/bash

sudo pacman -Syyy

for PKG in $(cat PKGS_BASIC.txt); do
    echo "DOWNLOADING: $PKG"
    sudo pacman -S $PKG --noconfirm --needed
done

echo "exec i3" | cat > $HOME/.xinitrc

sudo systemctl enable lightdm

sudo localectl set-x11-keymap hu

# Graphics Drivers find and install
#if lspci | grep -E "NVIDIA|GeForce"; then
#    pacman -S nvidia --noconfirm --needed
#	nvidia-xconfig
if lspci | grep -E "Radeon"; then
    sudo pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
#elif lspci | grep -E "Integrated Graphics Controller"; then
fi

sudo echo "RADV_PERFTEST=aco" | cat > /etc/environment

pushd $HOME
mkdir Github
pushd $HOME/Github

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

popd
popd

yay -S brave-bin
yay -S corectrl

sudo cat corectrl.rules > /etc/polkit-1/rules.d/90-corectrl.rules

sudo sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=\GRUB_CMDLINE_LINUX_DEFAULT=amdgpu.ppfeaturemask=0xffffffff/'

sudo grub-mkconfig -o /boot/grub/grub.cfg

mkdir $HOME/.config/compton
touch $HOME/.config/compton/compton.conf
mkdir $HOME/.config/i3
touch $HOME/.config/i3/config

cat config > $HOME/.config/i3/config
cp wallpaper.jpg $HOME/Pictures/wallpaper.jpg
cat compton.conf > $HOME/.config/compton/compton.conf
