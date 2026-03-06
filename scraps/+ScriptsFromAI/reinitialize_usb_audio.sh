#!/bin/bash
# Script to reinitialize the Creative SB X-Fi USB sound card

OUTPUT_FILE="/tmp/reinitialize_usb_audio_result.txt"

{
  echo "### Unbinding and Rebinding USB Sound Card ###"
  # Find the device ID for the Creative SB X-Fi
  DEVICE_ID=$(lsusb | grep -i 'SB X-Fi' | awk '{print $2"/"$4}' | sed 's/://')

  if [[ -z "$DEVICE_ID" ]]; then
    echo "Error: USB sound card not found."
    exit 1
  fi

  echo "Device ID: $DEVICE_ID"

  # Unbind and rebind the USB device
  echo "$DEVICE_ID" | sudo tee /sys/bus/usb/drivers/usb/unbind
  echo "$DEVICE_ID" | sudo tee /sys/bus/usb/drivers/usb/bind
  echo "USB device reinitialized."
  echo

  echo "### Restarting PipeWire Services ###"
  systemctl --user restart pipewire pipewire-pulse
  echo "PipeWire services restarted."
} > "$OUTPUT_FILE"

# Compress and output a return string
gzip -c "$OUTPUT_FILE" | base64 -w 0
echo ""
