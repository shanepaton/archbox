#!/usr/bin/env bash
#--------------------__----__--------------              
#   ____ ___________/ /_  / /_  ____  _  __
#  / __ `/ ___/ ___/ __ \/ __ \/ __ \| |/_/
# / /_/ / /  / /__/ / / / /_/ / /_/ />  <  
# \__,_/_/   \___/_/ /_/_.___/\____/_/|_|
#-----------------by shbox-----------------

echo "[archbox]: Installing Arch Linux"

# Get user input for disk and network
lsblk
echo "[archbox]: Enter disk to install to (ex. /dev/nvme0n1):"
read DISK
ip link
echo "[archbox]: Enter WiFi network device (ex. wlan0):"
read NETDEV
echo "[archbox]: Enter WiFi network name (ex. Epic-WiFi):"
read NETNAME
echo "[archbox]: Enter WiFi network password (ex. V3RYS3CUR3PW):"
read NETPW

# Configure WiFi
echo "[archbox]: Configuring WiFi..."
iwctl --passphrase ${NETPW} station ${NETDEV} connect ${NETNAME}
ip link

# Partition and format the disk
echo "[archbox]: Partitioning and formatting (${DISK})..."
sgdisk -n 5:0:+1000M ${DISK}
sgdisk -n 6:0:0 ${DISK}
sgdisk -t 5:ef00 ${DISK}
sgdisk -t 6:8300 ${DISK}
mkfs.ext4 "${DISK}p6"
mkfs.fat -F 32 "${DISK}p5"

# Mount partitions
echo "[archbox]: Mounting Partitions..."
mount "${DISK}p6" /mnt
mkdir -p /mnt/boot
mount "${DISK}p5" /mnt/boot

# Install base system
echo "[archbox]: Installing Linux Kernel and base system..."
pacstrap /mnt base linux linux-firmware --noconfirm --needed

# Generate fstab
echo "[archbox]: Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Start chroot environment
echo "[archbox]: Enter system hostname:"
read HOSTNAME
echo "[archbox]: Enter root password:"
read UACRPW
echo "[archbox]: Enter username:"
read UACNAME
echo "[archbox]: Enter password:"
read UACPW

arch-chroot /mnt /bin/bash <<EOF
# Set timezone and synchronize hardware clock
echo "[archbox]: Setting timezone..."
ln -sf /usr/share/zoneinfo/America/Regina /etc/localtime
hwclock --systohc

# Configure locale
echo "[archbox]: Setting Locales..."
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# Set hostname
echo "[archbox]: Setting Hostname..."
echo "$HOSTNAME" > /etc/hostname 

# Install necessary packages
echo "[archbox]: Installing packages..."
pacman -S --noconfirm --needed grub efibootmgr dhcpcd iwd nano vi vim sudo neofetch cmatrix htop ntp zsh git os-prober

# Create user
echo "[archbox]: Creating main user..."
useradd -m -g wheel $UACNAME
echo "$UACNAME:$UACPW" | chpasswd

# Configure GRUB bootloader
echo "[archbox]: Configuring GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
os-prober
grub-mkconfig -o /boot/grub/grub.cfg

# Create swap file
echo "[archbox]: Creating swap file..."
dd if=/dev/zero of=/swapfile bs=1M count=8192 status=progress
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

# Set root password
echo "root:$UACRPW" | chpasswd

# Reminder to enable network services
echo "[archbox]: On restart, enable iwd.service and dhcpcd.service!"

echo "[archbox]: Arch Linux install complete."
echo "[archbox]: See ya on the flip side..."
EOF

# Unmount and finish
umount -R /mnt
echo "[archbox]: Installation complete. Reboot the system to start using Arch Linux."
