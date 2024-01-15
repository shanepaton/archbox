#!/usr/bin/env bash
#--------------------__----__--------------              
#   ____ ___________/ /_  / /_  ____  _  __
#  / __ `/ ___/ ___/ __ \/ __ \/ __ \| |/_/
# / /_/ / /  / /__/ / / / /_/ / /_/ />  <  
# \__,_/_/   \___/_/ /_/_.___/\____/_/|_|
#-----------------by shbox-----------------                                   

echo "[archbox]: Installing Arch Linux"

lsblk
echo "[archbox]: Enter disk to install to. (ex. /dev/nvme0n1):"
read DISK
ip link
echo "[archbox]: Enter WiFi network device (ex. wlan0):"
read NETDEV
echo "[archbox]: Enter WiFi network name (ex. Epic-WiFi):"
read NETNAME
echo "[archbox]: Enter WiFi network password (ex. V3RYS3CUR3PW):"
read NETPW

echo "[archbox]: Configuring WiFi..."
iwctl --passphrase ${NETPW} station ${NETDEV} connect ${NETNAME}
ip link

echo "[archbox]: Partitioning and formatting (${DISK})..."
sgdisk -n 5:0:+1000M ${DISK}
sgdisk -n 6:0:0 ${DISK}
sgdisk -t 5:ef00 ${DISK}
sgdisk -t 6:8300 ${DISK}
mkfs.ext4 "${DISK}p6"
mkfs.fat -F 32  "${DISK}p5"

echo "[archbox]: Mounting Partitons..."
mount /dev/nvme0n1p6 /mnt
mount --mkdir /dev/nvme0n1p5 /mnt/boot

echo "[archbox]: Installing Linux Kernal..."
pacstrap -K /mnt base linux linux-firmware --noconfirm --needed

echo "[archbox]: Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

cp /archbox-b-chroot.sh /mnt/archbox-b-chroot.sh
cp /archbox-c-chroot.sh /mnt/archbox-c-postinstall.sh
echo "[archbox]: Inital setup complete, chroot and execute archbox-chroot.sh to finalize setup. See ya on the flip side..."
