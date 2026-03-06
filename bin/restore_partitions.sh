
#!/bin/bash
# Paths
NEW_DRIVE="/dev/sdX"                        # Replace with the path to the new drive
TEMP_DRIVE_PATH="/media/akienm/1TBUSBSSD1"  # Temporary storage path

# Ensure the temporary drive is mounted
if [ ! -d "$TEMP_DRIVE_PATH" ]; then
  echo "Temporary drive not mounted at $TEMP_DRIVE_PATH. Mount it and retry."
  exit 1
fi

# Confirm the new drive path
echo "The new drive is set to $NEW_DRIVE."
lsblk
read -p "Ensure $NEW_DRIVE is correct. Type 'yes' to proceed: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Operation canceled by the user."
  exit 1
fi

# Restore partitions
for PART_NAME in sdb1 sdb3 sdb4 sdb5 sdb6 sdb7; do
  IMAGE_FILE="$TEMP_DRIVE_PATH/${PART_NAME}.img.gz"
  PARTITION="${NEW_DRIVE}${PART_NAME/sdb/}"

  echo "Restoring $IMAGE_FILE to $PARTITION..."
  gzip -dc "$IMAGE_FILE" | sudo dd of="$PARTITION" bs=64K status=progress
  if [ $? -ne 0 ]; then
    echo "Restore failed for $PARTITION! Check the device and try again."
    exit 1
  fi
  echo "Restore of $PART_NAME complete."
done

# Restore /dev/sdb2 from the file-based archive
echo "Restoring /dev/sdb2 files to ${NEW_DRIVE}2..."
sudo mkfs.ext4 "${NEW_DRIVE}2"
sudo mount "${NEW_DRIVE}2" /mnt/new_sdb2 || {
  echo "Failed to mount ${NEW_DRIVE}2. Check the partition and retry."
  exit 1
}
sudo tar -xzvf "$TEMP_DRIVE_PATH/sdb2.tar.gz" -C /mnt/new_sdb2
sudo umount /mnt/new_sdb2
if [ $? -ne 0 ]; then
  echo "Restore of /dev/sdb2 failed! Check the archive and partition."
  exit 1
fi
echo "Restore of /dev/sdb2 complete."

# Finish
echo "All partitions have been restored to $NEW_DRIVE. The new drive is ready."
