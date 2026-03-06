#!/bin/bash
# Script to reset the audio configuration for the Creative SB X-Fi USB Sound Card

OUTPUT_FILE="/tmp/reset_audio_result.txt"

{
  echo "### Identifying Audio Server ###"
  if command -v pactl &> /dev/null; then
    if pactl info | grep -q PipeWire; then
      echo "Audio Server: PipeWire"
      SERVER="PipeWire"
    else
      echo "Audio Server: PulseAudio"
      SERVER="PulseAudio"
    fi
  else
    echo "Error: pactl command not found. Cannot identify audio server."
    exit 1
  fi
  echo

  echo "### Resetting Configuration ###"
  if [[ "$SERVER" == "PulseAudio" ]]; then
    pactl unload-module module-alsa-card
    pactl load-module module-alsa-card device_id=0
    echo "PulseAudio: Reset completed."
  elif [[ "$SERVER" == "PipeWire" ]]; then
    systemctl --user restart pipewire pipewire-pulse
    echo "PipeWire: Reset completed."
  else
    echo "Error: Unknown audio server."
    exit 1
  fi
  echo

  echo "### Verifying Device Configuration ###"
  pactl list sinks
} > "$OUTPUT_FILE"

# Compress and output a return string
gzip -c "$OUTPUT_FILE" | base64 -w 0
