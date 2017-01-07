#! /bin/bash

fdisk -l

mkfs.ext4 -c /dev/sdaR

mkswap --check /dev/sdaS
swapon /dev/sdaS

mount /dev/sdaR /mnt
mount /dev/sdaB /mnt/boot

#descomentando o mirrorlist do Brazil

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt

echo "en_US.UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8

ln -s /usr/share/zoneinfo/America/Bahia > /etc/localtime
hwclock --systohc --utc

pacman -S grub os-prober

grub-install --recheck --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo sylviot > /etc/hostname
passwd

exit

umount -R /mnt
reboot