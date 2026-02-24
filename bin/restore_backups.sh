#!/bin/bash

# Paths
BACKUP_BASE="/media/akienm/1TBUSBSSD1"
MOUNT_BASE="/media/akienm"
DISK="/dev/sdb"

# Partition mount points
PARTITIONS=("sdb1" "sdb2" "sdb3" "sdb4" "sdb5" "sdb6" "sdb7")

# Create mount points
echo "Creating mount points..."
for PART in "${PARTITIONS[@]}"; do
    MOUNT_POINT="$MOUNT_BASE/$PART"
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
        echo "Created mount point: $MOUNT_POINT"
    fi
done

# Mount partitions
echo "Mounting partitions..."
mount "${DISK}2" "$MOUNT_BASE/sdb2"
mount "${DISK}3" "$MOUNT_BASE/sdb3"
mount "${DISK}4" "$MOUNT_BASE/sdb4"
mount "${DISK}5" "$MOUNT_BASE/sdb5"
mount "${DISK}6" "$MOUNT_BASE/sdb6"
mount "${DISK}7" "$MOUNT_BASE/sdb7"
echo "All partitions mounted."

# Restore data
echo "Restoring data from backups..."
rsync -avh --progress "$BACKUP_BASE/sdb2/" "$MOUNT_BASE/sdb2/"
rsync -avh --progress "$BACKUP_BASE/sdb3/" "$MOUNT_BASE/sdb3/"
rsync -avh --progress "$BACKUP_BASE/sdb4/" "$MOUNT_BASE/sdb4/"
rsync -avh --progress "$BACKUP_BASE/sdb5/" "$MOUNT_BASE/sdb5/"
rsync -avh --progress "$BACKUP_BASE/sdb6/" "$MOUNT_BASE/sdb6/"
rsync -avh --progress "$BACKUP_BASE/sdb7/" "$MOUNT_BASE/sdb7/"
echo "Data restoration complete."

# Unmount partitions
echo "Unmounting partitions..."
for PART in "${PARTITIONS[@]}"; do
    umount "$MOUNT_BASE/$PART"
    echo "Unmounted $MOUNT_BASE/$PART"
done

echo "All tasks completed successfully."
