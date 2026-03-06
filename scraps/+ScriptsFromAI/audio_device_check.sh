#!/bin/bash

# File to save output
output_file="/home/akienm/audio_device_check_output.txt"

# Collect output of relevant commands
echo "Running 'pactl list cards'..." >> "$output_file"
pactl list cards >> "$output_file"
echo "" >> "$output_file"

echo "Running 'pactl list sinks'..." >> "$output_file"
pactl list sinks >> "$output_file"
echo "" >> "$output_file"

echo "Running 'aplay -l'..." >> "$output_file"
aplay -l >> "$output_file"
echo "" >> "$output_file"

echo "Running 'pw-cli ls Node'..." >> "$output_file"
pw-cli ls Node >> "$output_file"
echo "" >> "$output_file"

# Compress the output file
tar -czf /home/akienm/audio_device_check_output.tar.gz -C /home/akienm audio_device_check_output.txt

# Provide the location of the compressed file
echo "Output saved and compressed as /home/akienm/audio_device_check_output.tar.gz"
cat /home/akienm/audio_device_check_output.tar.gz
echo ""
