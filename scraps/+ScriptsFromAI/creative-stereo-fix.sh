#!/bin/bash

TMPFILE=$(mktemp)

# Create more detailed ALSA config for Creative X-Fi
cat << 'EOF' > ~/.asoundrc
# Define hardware device
pcm.creative_hw {
    type hw
    card 0
    device 0
    format S16_LE
    rate 48000
    channels 2
}

# Create unmixed stereo device
pcm.creative_stereo {
    type route
    slave.pcm "creative_hw"
    slave.channels 2
    ttable {
        0.0 1.0     # left to left only
        1.1 1.0     # right to right only
    }
}

# Set as default device
pcm.!default {
    type plug
    slave.pcm "creative_stereo"
}

ctl.!default {
    type hw
    card 0
}
EOF

# Stop PulseAudio
pulseaudio --kill
sleep 2

# Remove any existing PulseAudio configuration
rm -rf ~/.config/pulse/*

# Create custom PulseAudio daemon config
mkdir -p ~/.config/pulse
cat << 'EOF' > ~/.config/pulse/daemon.conf
default-sample-channels = 2
default-channel-map = front-left,front-right
enable-remixing = no
remixing-produce-lfe = no
remixing-consume-lfe = no
EOF

# Start PulseAudio with new config
pulseaudio --start
sleep 2

# Verify configuration
echo "=== ALSA Configuration ===" >> $TMPFILE
cat ~/.asoundrc >> $TMPFILE

echo -e "\n=== PulseAudio Configuration ===" >> $TMPFILE
cat ~/.config/pulse/daemon.conf >> $TMPFILE

echo -e "\n=== Current Sound Card Status ===" >> $TMPFILE
amixer -c 0 contents >> $TMPFILE

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE

echo "Configuration complete. Please test audio now."
