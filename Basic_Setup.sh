#! /bin/bash

pacman -S networkmanager grub efibootmgr os-prober git --noconfirm

systemctl enable NetworkManager

echo "-- GRUB EFI Bootloader Install&Check--"
echo "--------------------------------------"

echo "KEYMAP=hu" | cat > /etc/vconsole.conf

read -p "which is your boot drive? (exemple: /dev/sda) " B_DRIVE

if [[ -d "/sys/firmware/efi" ]]
then
    grub-install --target=x86_64-efi  --efi-directory=/boot --bootloader-id=GRUB ${B_DRIVE}
else
    grub-install ${B_DRIVE}
fi


grub-mkconfig -o /boot/grub/grub.cfg

echo "Add a root password: "

passwd

sed -i 's/#es_US.UTF-8/es_US.UTF-8/' /etc/locale.gen
sed -i 's/#es_US ISO-8859-1/es_US ISO-8859-1/' /etc/locale.gen
locale-gen

echo "LANG=en-US.UTF-8" | cat > /etc/loacle.conf

read -p "choose a hostname:" HOSTNAME

echo $HOSTNAME | cat > /etc/hostname

ln -sf /usr/share/zoneinfo/Europe/Budapest etc/localtime

read -p "Add a username:" USER

useradd -mg wheel $USER

passwd $USER

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

#
# determine processor type and install microcode
#
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

mkdir /home/$USER/Music
mkdir /home/$USER/Picturs
mkdir /home/$USER/Downloads
mkdir /home/$USER/Templates
mkdir /home/$USER/Videos
mkdir /home/$USER/Public

cd /home/$USER/Downloads
git clone https://github.com/onebe6/guinstaller
#cd guinstaller
#bash GUI_AND_PACKAGES.sh
