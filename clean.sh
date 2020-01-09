#!/bin/bash

set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# sudo mv /mnt/RPi/etc/resolv.conf.bak /mnt/RPi/etc/resolv.conf
sudo rm -f /mnt/RPi/usr/bin/qemu-arm-static

# TODO remove repetetion, use variables
if mountpoint -q /mnt/RPi/dev; then
  echo "  Unmounting /mnt/RPi/dev"
  sudo umount -l /mnt/RPi/dev
fi
if mountpoint -q /mnt/RPi/proc; then
  echo "  Unmounting /mnt/RPi/proc"
  sudo umount /mnt/RPi/proc
fi
if mountpoint -q /mnt/RPi/sys; then
  echo "  Unmounting /mnt/RPi/sys"
  sudo umount /mnt/RPi/sys
fi
if mountpoint -q /mnt/RPi/boot; then
  echo "  Unmounting /mnt/RPi/boot"
  sudo umount /mnt/RPi/boot
fi
if mountpoint -q /mnt/RPi; then
  echo "  Unmounting /mnt/RPi"
  sudo umount -Rlf /mnt/RPi
fi

sudo losetup --detach "/dev/loop0"

