#! /bin/bash

fdisk -l

mkfs.ext4 -c /dev/sda3

mkswap --check /dev/sda2
swapon /dev/sda2

mount /dev/sda3 /mnt

mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
curl -s "https://www.archlinux.org/mirrorlist/?country=BR&protocol=http&protocol=https&use_mirror_status=on" > /etc/pacman.d/mirrorlist
sed 's/\#Server/Server/g' /etc/pacman.d/mirrorlist

pacstrap -i /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
echo "sylviot" > /etc/hostname

locale >/etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
export LANG=en_US.UTF-8
locale-gen

ln -s /usr/share/zoneinfo/America/Bahia > /etc/localtime
hwclock --systohc --utc

pacman -Sy --noconfirm grub os-prober

grub-install --recheck --target=i386-pc /dev/sda
grub-mk n  nconfig -o /boot/grub/grub.cfg

passwd

EOF

umount -R /mnt
reboot