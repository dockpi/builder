#!/bin/bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# Load Config
. ./config.sh

# TODO Enable checks using shellcheck

# TODO Check if image exists, if it does, delete it after a prompt
# TODO --force flag should auto delete image
# TODO image pass size as an argument

if [ -f "$CUSTOM_IMAGE_FILENAME" ]; then
  echo "$CUSTOM_IMAGE_FILENAME exists, deleting it"
  rm "$CUSTOM_IMAGE_FILENAME"
fi
fallocate -l 3.0G "$CUSTOM_IMAGE_FILENAME"


# TODO Get output in a variable
# TODO /dev/loop0 should be a variable
export VIRTUAL_DEVICE=$(sudo losetup --find --show "$CUSTOM_IMAGE_FILENAME")

# Format the device
sudo parted --script /dev/loop0 mklabel msdos
sudo parted --script /dev/loop0 mkpart primary fat32 0% 100M
sudo parted --script /dev/loop0 mkpart primary ext4 100M 100%

sudo mkfs.vfat -F32 /dev/loop0p1
sudo mkfs.ext4 -F /dev/loop0p2


# Mount the device
sudo mkdir -p /mnt/RPi
sudo mount /dev/loop0p2 /mnt/RPi
sudo mkdir -p /mnt/RPi/boot
sudo mount /dev/loop0p1 /mnt/RPi/boot


if [ -f "$DOWNLOADED_IMAGE_FILENAME" ]; then
  echo "$DOWNLOADED_IMAGE_FILENAME already exists"
else
  echo "$DOWNLOADED_IMAGE_FILENAME does not exist"
  wget -O "$DOWNLOADED_IMAGE_FILENAME" "$ORIGINAL_IMAGE_URL"
fi


# Installing base image
sudo tar -xpf "$DOWNLOADED_IMAGE_FILENAME" -C /mnt/RPi

# Mounts required for chroot into the image
sudo mount -t proc none  /mnt/RPi/proc
sudo mount -t sysfs none /mnt/RPi/sys
sudo mount -o bind /dev  /mnt/RPi/dev

# For networking
sudo mv /mnt/RPi/etc/resolv.conf /mnt/RPi/etc/resolv.conf.bak
sudo cp /etc/resolv.conf /mnt/RPi/etc/resolv.conf

# Get ARM executables on x86_64
sudo cp /usr/bin/qemu-arm-static /mnt/RPi/usr/bin/

# Chroot
sudo cp chroot.sh /mnt/RPi/root/chroot.sh
sudo cp config.sh /mnt/RPi/root/config.sh
sudo chroot /mnt/RPi /root/chroot.sh

# Exit with success
printf -- '\n';
exit 0

