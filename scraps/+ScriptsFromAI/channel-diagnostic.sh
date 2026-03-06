#!/bin/bash

TMPFILE=$(mktemp)

echo "=== PulseAudio Card Profiles ===" >> $TMPFILE
pacmd list-cards | grep -A 50 "name: <alsa_card.usb" >> $TMPFILE

echo -e "\n=== Current Sink Settings ===" >> $TMPFILE
pacmd list-sinks | grep -A 50 "name: <alsa_output.usb" >> $TMPFILE

echo -e "\n=== Channel Map ===" >> $TMPFILE
pacmd list-sinks | grep -A 10 "channel map" >> $TMPFILE

echo -e "\n=== ALSA Hardware Parameters ===" >> $TMPFILE
amixer -c 0 contents >> $TMPFILE

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE
