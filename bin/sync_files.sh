#!/bin/bash

# Define the directories
FIRST_DIR="/media/akienm/AkiensWorld/AudioByCategory/Music"
SECOND_DIR="/media/akienm/AkiensWorld/AudioByCategory/MUSIC-SORTUS/MUSIC-OLD-SORTUS"

# Dry run mode: set to 1 for a dry run, where no actual overwrites or deletions occur
DRY_RUN=0  # Set to 0 to perform actual operations

# Use Python to compute file hashes, compare, and manage files
python3 <<EOF
import os
import hashlib
import shutil

# Directories to compare and modify
first_dir = "$FIRST_DIR"
second_dir = "$SECOND_DIR"
dry_run = $DRY_RUN

# Function to compute the SHA-256 hash of a file
def compute_hash(file_path):
    hasher = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hasher.update(chunk)
    return hasher.hexdigest()

# Function to remove empty directories recursively
def remove_empty_dirs(directory):
    for root, dirs, files in os.walk(directory, topdown=False):
        for dir_ in dirs:
            dir_path = os.path.join(root, dir_)
            if not os.listdir(dir_path):  # If directory is empty
                print(f"Removing empty directory: {dir_path}")
                if not dry_run:
                    os.rmdir(dir_path)

# Traverse the second directory to compare and potentially overwrite files in the first directory
for root, _, files in os.walk(second_dir):
    for file in files:
        second_file_path = os.path.join(root, file)
        # Determine the relative path of the file within the second directory
        relative_path = os.path.relpath(second_file_path, second_dir)
        # Determine the corresponding file path in the first directory
        first_file_path = os.path.join(first_dir, relative_path)

        # Check if the file exists in the first directory
        if os.path.exists(first_file_path):
            # Compute hashes for both files
            hash_first = compute_hash(first_file_path)
            hash_second = compute_hash(second_file_path)

            # If hashes match, replace the file in the first directory
            if hash_first == hash_second:
                print(f"Overwriting: {first_file_path} with {second_file_path}")
                if not dry_run:
                    # Create parent directories in the first directory if they don't exist
                    os.makedirs(os.path.dirname(first_file_path), exist_ok=True)
                    # Copy the file from the second directory to the first
                    shutil.copy2(second_file_path, first_file_path)
        else:
            # If the file doesn't exist in the first directory, move it there
            print(f"Moving: {second_file_path} to {first_file_path}")
            if not dry_run:
                os.makedirs(os.path.dirname(first_file_path), exist_ok=True)
                shutil.move(second_file_path, first_file_path)

# After processing, remove any empty directories from the second directory
remove_empty_dirs(second_dir)

EOF

# Notify the user about the dry run or actual execution
if [ $DRY_RUN -eq 1 ]; then
    echo "Dry run completed. No files were modified or deleted."
else
    echo "Operation completed. Files were overwritten/moved, and empty directories were removed."
fi
