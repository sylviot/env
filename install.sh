#! /bin/bash

fdisk -l

mkfs.ext4 -c /dev/sda3

mkswap --check /dev/sdaS
swapon /dev/sdaS

mount /dev/sda3 /mnt
#mount /dev/sdaB /mnt/boot

#descomentando o mirrorlist do Brazil

pacstrap -i /mnt base-devel

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt /bin/bash

echo "en_US.UTF-8" > /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8

ln -s /usr/share/zoneinfo/America/Bahia > /etc/localtime
hwclock --systohc --utc

pacman -Sy
pacman -S --noconfirm grub os-prober

grub-install --recheck --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo sylviot > /etc/hostname
# passwd

exit

umount -R /mnt
echo "END"
#reboot