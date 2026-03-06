#!/bin/bash
# Paths
OLD_DRIVE="/dev/sdb"                        # Source drive
TEMP_DRIVE_PATH="/media/akienm/1TBUSBSSD1"  # Temporary storage path

# Ensure the temporary drive is mounted
if [ ! -d "$TEMP_DRIVE_PATH" ]; then
  echo "Temporary drive not mounted at $TEMP_DRIVE_PATH. Mount it and retry."
  exit 1
fi

# Warn the user about deleting temporary drive contents
echo "WARNING: All contents of $TEMP_DRIVE_PATH will be deleted!"
read -p "Type 'yes' to confirm: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Operation canceled by the user."
  exit 1
fi

# Clear the temporary drive
echo "Clearing contents of $TEMP_DRIVE_PATH..."
sudo rm -rf "$TEMP_DRIVE_PATH"/*
echo "Temporary drive is cleared."

# Backup partitions except /dev/sdb2
for PARTITION in /dev/sdb1 /dev/sdb3 /dev/sdb4 /dev/sdb5 /dev/sdb6 /dev/sdb7; do
  PART_NAME=$(basename "$PARTITION")
  IMAGE_FILE="$TEMP_DRIVE_PATH/${PART_NAME}.img.gz"

  echo "Backing up $PARTITION to $IMAGE_FILE..."
  sudo dd if="$PARTITION" bs=64K status=progress | gzip > "$IMAGE_FILE"
  if [ $? -ne 0 ]; then
    echo "Backup failed for $PARTITION! Check the device and try again."
    exit 1
  fi
  echo "Backup of $PARTITION complete."
done

# Backup /dev/sdb2 as a file-based archive
echo "Backing up /dev/sdb2 (file-based) to $TEMP_DRIVE_PATH/sdb2.tar.gz..."
sudo mount /dev/sdb2 /mnt/sdb2 || {
  echo "Failed to mount /dev/sdb2. Ensure it's not in use and retry."
  exit 1
}
sudo tar -czvf "$TEMP_DRIVE_PATH/sdb2.tar.gz" -C /mnt/sdb2 .
sudo umount /mnt/sdb2
if [ $? -ne 0 ]; then
  echo "Backup of /dev/sdb2 failed! Check the partition and try again."
  exit 1
fi
echo "Backup of /dev/sdb2 complete."

# Finish
echo "All partitions have been backed up to $TEMP_DRIVE_PATH."
