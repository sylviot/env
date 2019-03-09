#!/bin/bash
set -e

MEMORYSIZE=$(sudo cat /proc/meminfo | grep MemTotal | grep -Eo "[0-9]*")

fdisk /dev/sda << EOF
n
p
1

+512M
n
p
2

+$MEMORYSIZE
n
p
3


w
EOF

fdisk -l

# /dev/sda1 - boot
# /dev/sda2 - swap
# /dev/sda3 - /

mkswap --check /dev/sda2
swapon /dev/sda2

mkfs.ext4 -c /dev/sda3
mount /dev/sda3 /mnt

pacstrap /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab

cat <<EOF > /mnt/script.sh

pacman -Sy --noconfirm grub os-prober sudo

echo "Configuration hostname..."
echo "sylviot" > /etc/hostname

useradd -m -G wheel,users -s /bin/bash sylviot
sed -i -r 's/^#.(%wheel.[^PSWD]*$)/\1/' /etc/sudoers
passwd sylviot

locale >/etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
export LANG=en_US.UTF-8
locale-gen

rm -f /etc/localtime
ln -s /usr/share/zoneinfo/America/Porto_Velho /etc/localtime
hwclock --systohc --utc
timedatectl set-ntp true

systemctl enable dhcpcd

grub-install --recheck --target=i386-pc /dev/sda
sed -i -r 's/(^.*_TIMEOUT=)5/\10/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuration root passwd..."
passwd

EOF

arch-chroot /mnt bash -c "sh /script.sh"

umount -R /mnt

reboot
