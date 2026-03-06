#!/bin/bash
# Script to reset and configure the audio profile for the USB sound card

OUTPUT_FILE="/tmp/set_audio_profile_v2_result.txt"

{
  echo "### Listing Available Audio Devices and Properties ###"
  # List all nodes and properties to find the sound card
  pw-cli dump Node | grep -i -A 10 'SB X-Fi'

  echo
  echo "### Attempting to Reset and List Profiles ###"
  # Attempt to reset or set the profile using pactl
  CARD_NAME=$(pactl list cards short | grep -i 'SB X-Fi' | awk '{print $2}')

  if [[ -z "$CARD_NAME" ]]; then
    echo "Error: Card for SB X-Fi not found."
    exit 1
  fi

  echo "Card Name: $CARD_NAME"

  # List profiles for the card
  pactl list cards | grep -A 20 "$CARD_NAME" | grep -E 'Profile|Available'

  echo
  echo "### Attempting to Set Profile to output:stereo ###"
  pactl set-card-profile "$CARD_NAME" "output:stereo-fallback"

} > "$OUTPUT_FILE"

# Compress and output a return string
gzip -c "$OUTPUT_FILE" | base64 -w 0
echo ""
