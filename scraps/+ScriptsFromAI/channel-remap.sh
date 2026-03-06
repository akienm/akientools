#!/bin/bash

TMPFILE=$(mktemp)

echo "=== Remapping Audio Channels ===" >> $TMPFILE

# Kill existing PulseAudio
pulseaudio --kill
sleep 2

# Start PulseAudio
pulseaudio --start
sleep 2

# Get the source device name
DEVICE=$(pacmd list-sinks | grep -m1 "name:" | cut -d'<' -f2 | cut -d'>' -f1)

# Create a remap sink
echo "Creating remap sink..." >> $TMPFILE
pacmd load-module module-remap-sink \
    sink_name=stereo-matched \
    master="$DEVICE" \
    channels=2 \
    master_channel_map=front-left,front-right \
    channel_map=front-left,front-right \
    remix=no >> $TMPFILE 2>&1

# Set it as default
echo "Setting as default..." >> $TMPFILE
pacmd set-default-sink stereo-matched >> $TMPFILE 2>&1

# Verify configuration
echo -e "\n=== Current Configuration ===" >> $TMPFILE
echo "Sinks:" >> $TMPFILE
pacmd list-sinks | grep -E "name:|channel map:" >> $TMPFILE

echo -e "\n=== Loaded Modules ===" >> $TMPFILE
pacmd list-modules | grep remap >> $TMPFILE

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE

echo "Configuration complete. Please test audio now."
