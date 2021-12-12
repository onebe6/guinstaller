#! /bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

reflector -a 48 -c $iso -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist

pacman -S gptfdisk --noconfirm

lsblk

read -p "which drive do you want to partition?: (exemple: /dev/sda)" DISK

# disk prep
sgdisk -Z ${DISK} # zap all on disk

# creating partitions
if [[ -d "/sys/firmware/efi" ]]
then
    sgdisk -a 2048 -o ${DISK} # new gpt disk 2048 alignment
    sgdisk -n 1::+200M --typecode=1:ef00 --change-name=1:'EFIBOOT' ${DISK} # partition 2 (UEFI Boot Partition)
    sgdisk -n 2::-0 --typecode=2:8300 --change-name=2:'ROOT' ${DISK} # partition 3 (Root), default start, remaining
else
    echo "********************************************************************************************"
    echo "*You have a legacy system. You have to create a DOS partition and create a new 128M patition*"
    echo "*make it bootable by pressing B and write it and a new partition and write it****************"
    echo "*********************************************************************************************"
    read -p "Press any button if you have read the instuction above" ANY
    cfdisk ${DISK}
fi

lsblk

mkfs.ext4 ${DISK}2 #$PARTITION

mount ${DISK}2 /mnt #$PARTITION /mnt

if [[ -d "/sys/firmware/efi" ]]
then
    mkfs.vfat -F32 ${DISK}1 #$BOOT
    mkdir /mnt/boot
    mount ${DISK}1 /mnt/boot
else
    mkfs.ext4 ${DISK}1 #$BOOT
    mkdir /mnt/boot
    mount ${DISK}1 /mnt/boot
fi

pacstrap /mnt base base-devel linux linux-firmware vim nano

genfstab -U /mnt >> /mnt/etc/fstab

cp -R ${SCRIPT_DIR} /mnt/root/archinstall
