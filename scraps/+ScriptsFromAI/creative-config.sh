#!/bin/bash

TMPFILE=$(mktemp)

# Create custom ALSA config for Creative X-Fi
cat << 'EOF' > ~/.asoundrc
pcm.creative {
    type plug
    slave.pcm {
        type hw
        card 0
        device 0
    }
    ttable {
        0.0 1    # left channel only to left output
        1.1 1    # right channel only to right output
        0.1 0    # no left to right mixing
        1.0 0    # no right to left mixing
    }
}

pcm.!default {
    type plug
    slave.pcm "creative"
}

ctl.!default {
    type hw
    card 0
}
EOF

# Restart PulseAudio to pick up new config
pulseaudio --kill
sleep 2
pulseaudio --start
sleep 2

# Verify the configuration
echo "=== ALSA Configuration ===" >> $TMPFILE
cat ~/.asoundrc >> $TMPFILE

echo -e "\n=== Testing direct ALSA access ===" >> $TMPFILE
aplay -l | grep "card 0" >> $TMPFILE

echo -e "\n=== PulseAudio Sinks ===" >> $TMPFILE
pacmd list-sinks | grep -E "name:|device.description|channel map:" >> $TMPFILE

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE

echo "Configuration complete. Please test audio now."
