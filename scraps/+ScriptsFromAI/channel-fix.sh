#!/bin/bash

TMPFILE=$(mktemp)

echo "=== Current Audio Setup ===" >> $TMPFILE
echo "Setting up proper channel mapping..." >> $TMPFILE

# Kill existing PulseAudio
pulseaudio --kill
sleep 2

# Create new ALSA configuration
cat << EOF > ~/.asoundrc
pcm.!default {
    type plug
    slave.pcm "hw:0,0"
    slave.channels 2
    ttable.0.0 1.0
    ttable.1.1 1.0
}

ctl.!default {
    type hw
    card 0
}
EOF

# Start PulseAudio with new config
pulseaudio --start
sleep 2

# Set the card profile to analog stereo
echo "Setting card profile..." >> $TMPFILE
pacmd set-card-profile 0 output:analog-stereo 2>> $TMPFILE

# Set the default sink
echo "Setting default sink..." >> $TMPFILE
SINK=$(pacmd list-sinks | grep -m1 "name:" | cut -d'<' -f2 | cut -d'>' -f1)
pacmd set-default-sink "$SINK" 2>> $TMPFILE

# Set the channel map
echo "Setting channel map..." >> $TMPFILE
pacmd set-sink-channel-map "$SINK" "front-left,front-right" 2>> $TMPFILE

# Verify settings
echo -e "\n=== New Configuration ===" >> $TMPFILE
echo "ALSA Config:" >> $TMPFILE
cat ~/.asoundrc >> $TMPFILE

echo -e "\nPulseAudio Sink Status:" >> $TMPFILE
pacmd list-sinks | grep -A 3 "name:" >> $TMPFILE
pacmd list-sinks | grep -A 3 "channel map" >> $TMPFILE

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE

echo "Configuration complete. Please test audio now."
