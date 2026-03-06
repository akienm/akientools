#!/bin/bash

# Create a temporary file for our filtered output
TMPFILE=$(mktemp)

echo "=== PCI Info ===" >> $TMPFILE
lspci | grep -i audio >> $TMPFILE

echo -e "\n=== USB Info ===" >> $TMPFILE
lsusb | grep -i creative >> $TMPFILE

echo -e "\n=== Loaded Sound Modules ===" >> $TMPFILE
lsmod | grep -E "^snd" | awk '{print $1}' >> $TMPFILE

echo -e "\n=== ALSA Device List ===" >> $TMPFILE
arecord -l >> $TMPFILE
aplay -l >> $TMPFILE

echo -e "\n=== PulseAudio Status ===" >> $TMPFILE
pactl info 2>/dev/null >> $TMPFILE

echo -e "\n=== PulseAudio Sinks ===" >> $TMPFILE
pactl list short sinks >> $TMPFILE

echo -e "\n=== PulseAudio Sources ===" >> $TMPFILE
pactl list short sources >> $TMPFILE

echo -e "\n=== PulseAudio Cards ===" >> $TMPFILE
pactl list cards | grep -A 2 "Name:" >> $TMPFILE

# Output everything with base64 encoding to make it easier to paste
base64 $TMPFILE

# Cleanup
rm $TMPFILE
