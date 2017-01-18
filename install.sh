#! /bin/bash

fdisk -l

mkfs.ext4 -c /dev/sda3

mkswap --check /dev/sda2
swapon /dev/sda2

mount /dev/sda3 /mnt

rm -f /etc/pacman.d/mirrorlist
curl -s "https://www.archlinux.org/mirrorlist/?country=BR&country=US&protocol=http&protocol=https&use_mirror_status=on" > /etc/pacman.d/mirrorlist
sed -i 's/\#Server/Server/g' /etc/pacman.d/mirrorlist

pacstrap /mnt base base-devel

genfstab -U /mnt > /mnt/etc/fstab

cat <<EOF > /mnt/script.sh

echo "Configuration hostname..."
echo "sylviot" > /etc/hostname
passwd sylviot

useradd -m -G wheel,users -s /bin/bash sylviot
sed -i -r 's/^#.(%wheel.[^PSWD]*$)/\1/' /etc/sudores

locale >/etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
export LANG=en_US.UTF-8
locale-gen

rm -f /etc/localtime
ln -s /usr/share/zoneinfo/America/Bahia > /etc/localtime
hwclock --systohc --utc
timedatectl set-ntp true

systemctl enable dhcpcd

pacman -Sy --noconfirm grub os-prober

grub-install --recheck --target=i386-pc /dev/sda
sed -i -r 's/(^.*_TIMEOUT=)5/\10/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "Configuration root passwd..."
passwd

EOF

arch-chroot /mnt bash -c "sh /script.sh"

umount -R /mnt

reboot
