#!/usr/bin/env bash
#--------------------__----__--------------              
#   ____ ___________/ /_  / /_  ____  _  __
#  / __ `/ ___/ ___/ __ \/ __ \/ __ \| |/_/
# / /_/ / /  / /__/ / / / /_/ / /_/ />  <  
# \__,_/_/   \___/_/ /_/_.___/\____/_/|_|
#-----------------by shbox-----------------

echo "[archbox]: Enter system hostname:"
read HOSTNAME
echo "[archbox]: Enter root password:"
read UACRPW
echo "[archbox]: Enter username:"
read UACNAME
echo "[archbox]: Enter password:"
read UACPW

echo "[archbox]: Setting timezone..."
ln -sf /usr/share/zoneinfo/America/Regina /etc/localtime
hwclock --systohc

echo "[archbox]: Setting Locales..."
locale-gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

echo "[archbox]: Setting Hostname..."
echo $HOSTNAME > /etc/hostname 

echo "[archbox]: Installing packages..."
pacman -S --noconfirm --needed grub efibootmgr dhcpcd iwd nano vi vim sudo neofetch cmatrix htop ntp zsh git os-prober

echo "[archbox]: Creating main user..."
useradd -m -a wheel $UACNAME
yes $UACPW | passwd $UACNAME

echo "[archbox]: Configuring up GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
os-prober
grub-mkconfig -o /boot/grub/grub.cfg

echo "[archbox]: Creating swap file..."
dd if=/dev/zero of=/swapfile bs=1M count=8k status=progress
chmod 0600 /swapfile
mkswap -U clear /swapfile
swapon /swapfile
echo "\n/swapfile none swap defaults 0 0" >> /etc/fstab

echo "[archbox]: Setting root password..."
yes $UACRPW | passwd

echo "[archbox]: On restart enable iwd.service and dhcpcd.service!"

echo "[archbox]: Arch Linux install complete."
echo "[archbox]: See ya on the flip side..."
