#!/bin/bash
# Script to configure the audio profile for the Creative Labs SB1095 USB Sound Card

OUTPUT_FILE="/tmp/set_audio_profile_v3_result.txt"

{
  echo "### Listing Available PipeWire Nodes ###"
  pw-cli ls Node | grep -i 'SB X-Fi'

  echo
  echo "### Listing Available PipeWire Cards ###"
  pw-cli ls Card | grep -i 'SB X-Fi'

  echo
  echo "### Using pactl to List Cards ###"
  pactl list cards short | grep -i 'SB X-Fi'

  # Extract the card name from pactl
  CARD_NAME=$(pactl list cards short | grep -i 'SB X-Fi' | awk '{print $2}')
  if [[ -z "$CARD_NAME" ]]; then
    echo "Error: Card for SB X-Fi not found."
    exit 1
  fi

  echo
  echo "### Card Name: $CARD_NAME ###"
  echo "### Listing Available Profiles for the Card ###"
  pactl list cards | grep -A 20 "$CARD_NAME" | grep -E 'Profile|Available'

  echo
  echo "### Attempting to Set Profile to output:stereo ###"
  pactl set-card-profile "$CARD_NAME" "output:stereo-fallback"

  echo
  echo "### Final Verification ###"
  pactl list cards | grep -A 20 "$CARD_NAME"

} > "$OUTPUT_FILE"

# Compress and output the result
gzip -c "$OUTPUT_FILE" | base64 -w 0
echo ""
