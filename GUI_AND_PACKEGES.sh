#!/bin/bash

sudo pacman -Syyy

for PKG in $(cat PKGS_BASIC.txt); do
    echo "DOWNLOADING: $PKG"
    sudo pacman -S $PKG --noconfirm --needed
done

echo "exec i3" | cat > ~/.xinitrc

sudo systemctl enable lightdm

#sudo cp /etc/xdg/picom.conf ~/.config/picom/picom.conf

#picom --config ~/.config/picom/picom.conf

# Graphics Drivers find and install
#if lspci | grep -E "NVIDIA|GeForce"; then
#    pacman -S nvidia --noconfirm --needed
#	nvidia-xconfig
if lspci | grep -E "Radeon"; then
    sudo pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
#elif lspci | grep -E "Integrated Graphics Controller"; then
fi

sudo echo "RADV_PERFTEST=aco" | cat > /etc/environment

pushd ~
mkdir Github
pushd ~/Github

sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

popd
popd

#yay -S corectrl

#sudo cat corectrl.rules > /etc/polkit-1/rules.d/90-corectrl.rules

#sudo sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=\GRUB_CMDLINE_LINUX_DEFAULT=amdgpu.ppfeaturemask=0xffffffff/'

#sudo grub-mkconfig -o /boot/grub/grub.cfg

mkdir ~/.config/picom

cat config > ~/.config/i3/config
mv wallpaper.jpg ~/Pictures/wallpaper.jpg
cat picom.conf > ~/.config/picom/picom.conf

picom --config ~/.config/picom/picom.conf
