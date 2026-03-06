#!/bin/bash

TMPFILE=$(mktemp)

# Create ALSA config with explicit channel routing
cat << 'EOF' > ~/.asoundrc
pcm.!default {
    type plug
    slave {
        pcm {
            type hw
            card 0
            device 0
        }
        channels 2
        format S16_LE
    }
    ttable.0.0 1    # Left channel
    ttable.1.1 1    # Right channel
    ttable.0.1 0    # Explicitly zero cross-channel mixing
    ttable.1.0 0
}

defaults.pcm.dmix.rate 48000
defaults.pcm.dmix.format S16_LE

ctl.!default {
    type hw
    card 0
}
EOF

# Stop PulseAudio and clean up
pulseaudio --kill
sleep 2
rm -rf ~/.config/pulse/*

# Create PulseAudio config
mkdir -p ~/.config/pulse
cat << 'EOF' > ~/.config/pulse/daemon.conf
default-sample-format = s16le
default-sample-rate = 48000
default-sample-channels = 2
default-channel-map = front-left,front-right
enable-remixing = no
enable-lfe-remixing = no
flat-volumes = no
EOF

# Force card configuration
cat << 'EOF' > ~/.config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-alsa-sink device=hw:0,0 channels=2 channel_map=front-left,front-right
set-default-sink 0
EOF

# Start PulseAudio with new config
pulseaudio --start
sleep 2

# Verify current settings
echo "=== ALSA Configuration ===" >> $TMPFILE
cat ~/.asoundrc >> $TMPFILE

echo -e "\n=== PulseAudio Configuration ===" >> $TMPFILE
cat ~/.config/pulse/daemon.conf >> $TMPFILE

echo -e "\n=== Current ALSA Settings ===" >> $TMPFILE
amixer -c 0 get 'Channel Map' >> $TMPFILE 2>&1

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE

echo "Configuration complete. Please test audio now."
