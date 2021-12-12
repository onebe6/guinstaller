#! /bin/bash

bash Alpha.sh
arch-chroot /mnt /root/archinstall/Basic_Setup.sh
umount -R /mnt
echo "
###############################################################################
# Done - Please Eject Install Media and Reboot
###############################################################################
"
#reboot
