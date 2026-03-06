#!/bin/bash

# Ensure the script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

# Define the device
DEVICE="/dev/sdb"

# Check if the device exists
if [ ! -b "$DEVICE" ]; then
  echo "Error: Device $DEVICE not found. Exiting."
  exit 1
fi

echo "Starting partitioning of $DEVICE..."

# Create a GPT partition table and partitions
sgdisk --zap-all "$DEVICE"  # Wipe any existing partition table
sgdisk --new=1:2048:4196351 --typecode=1:fd00 "$DEVICE"  # Partition 1: linux_raid_member (Swap)
sgdisk --new=2:16779264:0 --typecode=2:8300 "$DEVICE"    # Partition 2: ext4 (Main data store, adjust to use remaining space)
sgdisk --new=3:14682112:16779263 --typecode=3:8300 "$DEVICE"  # Partition 3: ext4
sgdisk --new=4:4196352:6293503 --typecode=4:8300 "$DEVICE"    # Partition 4: ext4
sgdisk --new=5:6293504:8390655 --typecode=5:8300 "$DEVICE"    # Partition 5: ext4
sgdisk --new=6:8390656:12584959 --typecode=6:8300 "$DEVICE"   # Partition 6: ext4
sgdisk --new=7:12584960:14682111 --typecode=7:8300 "$DEVICE"  # Partition 7: ext4

# Sync to ensure changes are written
sync
echo "Partitioning complete."

# Format the partitions
echo "Formatting partitions..."
mkswap "${DEVICE}1"  # Partition 1: Swap
mkfs.ext4 "${DEVICE}2"  # Partition 2: ext4 (Main data store)
mkfs.ext4 "${DEVICE}3"  # Partition 3: ext4
mkfs.ext4 "${DEVICE}4"  # Partition 4: ext4
mkfs.ext4 "${DEVICE}5"  # Partition 5: ext4
mkfs.ext4 "${DEVICE}6"  # Partition 6: ext4
mkfs.ext4 "${DEVICE}7"  # Partition 7: ext4

# Verify the partitions
echo "Verifying partition table..."
lsblk "$DEVICE"
blkid "$DEVICE"*

echo "Partitioning and formatting completed successfully."
exit 0
