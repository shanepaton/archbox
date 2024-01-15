#!/usr/bin/env bash

#                    __    __              
#   ____ ___________/ /_  / /_  ____  _  __
#  / __ `/ ___/ ___/ __ \/ __ \/ __ \| |/_/
# / /_/ / /  / /__/ / / / /_/ / /_/ />  <  
# \__,_/_/   \___/_/ /_/_.___/\____/_/|_|                                   

# Install script by me to install Arch Linux on my laptop.

echo "[archbox]: Enter system hostname:"
read HOSTNAME

echo "[archbox]: Enter username:"
read UACNAME

echo "[archbox]: Enter  password:"
read UACPW

echo "[archbox]: Setting timezone..."

timedatectl --no-ask-password set-timezone America/Regina
timedatectl --no-ask-password set-ntp 1

hwclock --systohc

echo "[archbox]: Setting Locales..."

locale-gen
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

localectl --no-ask-password set-keymap us

echo "[archbox]: Setting Hostname..."

hostnamectl --no-ask-password set-hostname $HOSTNAME

echo "[archbox]: Installing packages..."

pacman -S --noconfirm --needed grub efibootmgr dhcpcd iwd nano vi vim sudo neofetch cmatrix htop ntp zsh git os-prober

echo "[archbox]: Creating user..."

usermod -m -aG wheel $UACNAME

yes $UACPW | passwd $UACNAME

echo "[archbox]: Setting up GRUB..."

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

os-prober

grub-mkconfig -o /boot/grub/grub.cfg

echo "[archbox]: If all went well, Arch Linux is installed."
echo "[archbox]: See ya on the flip side..."
