#!/bin/bash
# Gather system and sound card information for troubleshooting the stereo-to-mono issue

OUTPUT_FILE="/tmp/sound_info.txt"

{
  echo "### System Information ###"
  uname -a
  echo

  echo "### USB Devices ###"
  lsusb
  echo

  echo "### Sound Card Configuration ###"
  aplay -l
  echo

  echo "### PulseAudio/ PipeWire Information ###"
  pactl list sinks
  echo

  echo "### Alsa Configuration ###"
  cat /proc/asound/cards
  echo
  amixer -c 0 contents
} > "$OUTPUT_FILE"

# Compress and output a return string
gzip -c "$OUTPUT_FILE" | base64 -w 0
