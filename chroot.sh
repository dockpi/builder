#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# Load config
. /root/config.sh

ln -sf "/usr/share/zoneinfo/$TIMEZONE_LOCATION" /etc/localtime

# Uncomment en_US.UTF-8 from /etc/locale.gen
sed -i 's/\#en\_US\.UTF\-8\ UTF\-8/en\_US\.UTF\-8\ UTF\-8/g' /etc/locale.gen

{
  echo "LANG=en_US.UTF-8"
  echo "LC_CTYPE=en_US.UTF-8"
  echo "LC_MESSAGES=en_US.UTF-8"
  echo "LC_ALL=en_US.UTF-8"
  echo "LANGUAGE=\"en_US.UTF-8\""
} >> /etc/locale.conf

locale-gen

echo "$HOSTNAME" > /etc/hostname

{
  echo "127.0.0.1 localhost.localdomain localhost"
  echo "::1   localhost.localdomain localhost"
  echo "127.0.0.1 $HOSTNAME.localdomain $HOSTNAME"
} >> /etc/hosts

pacman-key --init
pacman-key --populate archlinuxarm

# Pacman customizations
sed -i 's/\#Color/Color/g' /etc/pacman.conf
sed -i 's/\#TotalDownload/TotalDownload/g' /etc/pacman.conf
sed -i 's/\#VerbosePkgLists/VerbosePkgLists/g' /etc/pacman.conf
sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf

# Default user is alarm
sed -i "s/alarm/$USERNAME/g" /etc/passwd /etc/group /etc/shadow
mv /home/alarm "/home/$USERNAME"
echo -e "$PASSWORD\n$PASSWORD" | passwd "$USERNAME"

# Enable RPi Camera
sed -i 's/gpu_mem=.*/gpu_mem=128/' /boot/config.txt
grep 'start_file=start_x.elf' /boot/config.txt >/dev/null || echo 'start_file=start_x.elf' >> /boot/config.txt
grep 'fixup_file=fixup_x.dat' /boot/config.txt >/dev/null || echo 'fixup_file=fixup_x.dat' >> /boot/config.txt

# Connect to WiFi
ln -sf /usr/lib/systemd/system/netctl-auto@.service /etc/systemd/system/multi-user.target.wants/netctl-auto@wlan0.service
ln -sf /usr/lib/systemd/system/netctl-ifplugd@.service /etc/systemd/system/multi-user.target.wants/netctl-ifplugd@eth0.service
cat <<EOF >"/etc/netctl/wlan0-SSID"
Description='Baked in profile'
Interface=wlan0
Connection=wireless
Security=wpa
ESSID="$SSID"
IP=dhcp
Key="$WIFI_PASSWORD"
EOF

# Install necessary packages
pacman -Syu --needed --noconfirm \
  archlinux-keyring \
  bash-completion \
  crda \
  dhcpcd \
  dialog \
  dnsutils \
  exfat-utils \
  git \
  ifplugd \
  iw \
  networkmanager \
  openssh \
  sudo \
  wpa_supplicant \
# Clear pacman cache
pacman -Sc --noconfirm

pacman -Syu --needed --noconfirm \
  aria2 \
  docker \
  docker-compose \
  htop \
  neovim \
  stow \
  tmux \
  tree \
  wireguard-tools \
  wireguard-dkms \
  zsh
# Clear pacman cache
pacman -Sc --noconfirm


# Enable passwordless sudo for wheel group
echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers.d/wheel
usermod -a -G wheel $USERNAME

# Enable SSH
mkdir -p ~/.ssh
mkdir -p /home/$USERNAME/.ssh
curl -L https://github.com/codingcoffee.keys >> ~/.ssh/authorized_keys
curl -L https://github.com/codingcoffee.keys >> /home/$USERNAME/.ssh/authorized_keys
systemctl enable sshd

# TODO Enable Docker and grant cc docker access
systemctl enable docker
usermod -a -G docker $USERNAME

# Cleanup
rm /root/config.sh
rm /root/chroot.sh

