#!/bin/bash
# Script to reset and configure the audio profile for the USB sound card

OUTPUT_FILE="/tmp/set_audio_profile_result.txt"

{
  echo "### Listing Available Audio Devices ###"
  # List all audio sinks and sources
  pw-cli ls Node | grep -E 'audio.adapter|node.name'
  echo

  echo "### Attempting to Set Profile ###"
  # Get the device ID for the USB sound card
  DEVICE_ID=$(pw-cli ls Node | grep -i 'SB X-Fi' | awk '{print $1}')

  if [[ -z "$DEVICE_ID" ]]; then
    echo "Error: Audio output device for SB X-Fi not found."
    exit 1
  fi

  echo "Device ID: $DEVICE_ID"

  # Attempt to set the profile to an output-capable one
  pw-cli set-prop "$DEVICE_ID" "node.profile" "output:stereo-fallback"

  echo "Profile set to output:stereo-fallback"
} > "$OUTPUT_FILE"

# Compress and output a return string
gzip -c "$OUTPUT_FILE" | base64 -w 0
echo ""
