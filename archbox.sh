#!/usr/bin/env bash

#                 _     _               
#                | |   | |              
#   __ _ _ __ ___| |__ | |__   _____  __
#  / _` | '__/ __| '_ \| '_ \ / _ \ \/ /
# | (_| | | | (__| | | | |_) | (_) >  < 
#  \__,_|_|  \___|_| |_|_.__/ \___/_/\_\                                      
# Install script by me to install Arch Linux on my laptop.

echo "[ARCHBOX]: Installing Arch Linux"

lsblk

echo "[ARCHBOX]: Enter disk to install to. (ex. /dev/nvme0n1):"
read DISK

ip link
echo "[ARCHBOX]: Enter WiFi network device:"
read NETDEV

echo "[ARCHBOX]: Enter WiFi network name:"
read NETNAME

echo "[ARCHBOX]: Enter WiFi network password:"
read NETPW

echo "[ARCHBOX]: Configuring WiFi..."

# ask for network name, device, and pw

iwctl --passphrase ${NETPW} station ${NETDEV} connect ${NETNAME}

ip link

echo "[ARCHBOX]: Setting time..."

timedatectl

echo "[ARCHBOX]: (${DISK}) Partitioning disk..."

# sgdisk: EFI, SWAP, ROOT
sgdisk -n 5:0:+1000M ${DISK}
sgdisk -n 6:0:+12000M ${DISK}
sgdisk -n 7:0:0 ${DISK}

# sgdisk: Assign partition types.
sgdisk -t 5:ef00 ${DISK}
sgdisk -t 6:8200 ${DISK}
sgdisk -t 7:8300 ${DISK}

echo "[ARCHBOX]: (${DISK}) partitioned."
echo "[ARCHBOX]: (${DISK}) Formating partitions..."

mkfs.ext4 "${DISK}p7"
mkswap "${DISK}p6"
mkfs.fat -F 32  "${DISK}p5"

echo "[ARCHBOX]: Partitons Formated."
echo "[ARCHBOX]: Mounting Partitons..."

mount /dev/nvme0n1p7 /mnt
mount --mkdir /dev/nvme0n1p5 /mnt/boot
swapon /dev/nvme0n1p6

echo "[ARCHBOX]: Partitons Mounted."
echo "[ARCHBOX]: Installing Linux Kernal..."

pacstrap -K /mnt base linux linux-firmware --noconfirm --needed

echo "[ARCHBOX]: Installed Linux Kernal."
echo "[ARCHBOX]: Generating fstab..."

genfstab -U /mnt >> /mnt/etc/fstab

echo "[ARCHBOX]: fstab Generated."

echo "[ARCHBOX]: Install complete. See ya on the flip side..."
