#!/usr/bin/env bash
#--------------------__----__--------------              
#   ____ ___________/ /_  / /_  ____  _  __
#  / __ `/ ___/ ___/ __ \/ __ \/ __ \| |/_/
# / /_/ / /  / /__/ / / / /_/ / /_/ />  <  
# \__,_/_/   \___/_/ /_/_.___/\____/_/|_|
#-----------------by shbox-----------------                                   

echo -e "--------------------__----__--------------\n   ____ ___________/ /_  / /_  ____  _  __\n  / __ \`/ ___/ ___/ __ \/ __ \/ __ \| |/_/\n / /_/ / /  / /__/ / / / /_/ / /_/ />  <\n \__,_/_/   \___/_/ /_/_.___/\____/_/|_|\n -----------------by shbox-----------------\n"
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
echo "[archbox]: Enter system hostname:"
read HOSTNAME
echo "[archbox]: Enter root password:"
read UACRPW
echo "[archbox]: Enter username:"
read UACNAME
echo "[archbox]: Enter password:"
read UACPW


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

echo "[archbox]: Inital setup complete, chroot and execute archbox-chroot.sh to finalize setup. See ya on the flip side..."

arch-chroot /mnt /bin/bash <<"EOT"

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
useradd -m -g wheel $UACNAME
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
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

echo "[archbox]: Setting root password..."
yes $UACRPW | passwd

echo "[archbox]: Patching /etc/sudoers..."
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "[archbox]: Creating post-install script..."
touch archbox-c-services.sh
echo "systemctl enable iwd.service" >> archbox-c-services.sh
echo "systemctl enable dhcpcd.service" >> archbox-c-services.sh
echo "systemctl start iwd.service" >> archbox-c-services.sh
echo "systemctl start dhcpcd.service" >> archbox-c-services.sh
echo "[archbox]: On restart run archbox-c-services.sh"

echo -e "--------------------__----__--------------\n   ____ ___________/ /_  / /_  ____  _  __\n  / __ \`/ ___/ ___/ __ \/ __ \/ __ \| |/_/\n / /_/ / /  / /__/ / / / /_/ / /_/ />  <\n \__,_/_/   \___/_/ /_/_.___/\____/_/|_|\n -----------------by shbox-----------------\n"
echo "[archbox]: Arch Linux install complete, see ya on the flip side."

EOT
