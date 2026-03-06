#!/bin/bash

# Comprehensive Audio Diagnosis and Recovery Script
LOGFILE="/home/akienm/audio_recovery.log"

echo "Audio Diagnosis and Recovery Log - $(date)" > "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check if the USB device is detected
echo "1. USB Devices (Filtered for SoundBlaster):" >> "$LOGFILE"
lsusb | grep -i "soundblaster\|creative" >> "$LOGFILE"
if [ $? -ne 0 ]; then
    echo "No SoundBlaster device found in lsusb." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Check ALSA device list for the SoundBlaster
echo "2. ALSA Devices (Filtered for SoundBlaster):" >> "$LOGFILE"
aplay -l | grep -i "soundblaster\|creative" >> "$LOGFILE" 2>&1
arecord -l | grep -i "soundblaster\|creative" >> "$LOGFILE" 2>&1
if [ $? -ne 0 ]; then
    echo "No SoundBlaster device found in ALSA device list." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Check PulseAudio status and sources/sinks
echo "3. PulseAudio Status and Sources/Sinks:" >> "$LOGFILE"
if command -v pactl > /dev/null; then
    systemctl --user status pulseaudio >> "$LOGFILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "PulseAudio is not running. Attempting to start..." >> "$LOGFILE"
        systemctl --user start pulseaudio >> "$LOGFILE" 2>&1
    fi
    pactl list short sinks | grep -i "soundblaster\|creative" >> "$LOGFILE"
    pactl list short sources | grep -i "soundblaster\|creative" >> "$LOGFILE"
else
    echo "PulseAudio is not installed or not found." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Check PipeWire status and nodes
echo "4. PipeWire Status and Nodes:" >> "$LOGFILE"
if command -v pw-cli > /dev/null; then
    systemctl --user status pipewire >> "$LOGFILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "PipeWire is not running. Attempting to start..." >> "$LOGFILE"
        systemctl --user start pipewire >> "$LOGFILE" 2>&1
    fi
    pw-cli dump | grep -i "soundblaster\|creative" >> "$LOGFILE"
else
    echo "PipeWire is not installed or not found." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Check kernel modules
echo "5. Kernel Modules (Relevant to Sound):" >> "$LOGFILE"
lsmod | grep -i "snd\|usb_audio" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check recent kernel logs for USB or audio-related errors
echo "6. Recent Kernel Logs (Filtered for USB/Audio):" >> "$LOGFILE"
dmesg | grep -i "usb\|audio\|sound" | tail -n 50 >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Restart audio services
echo "7. Restarting Audio Services:" >> "$LOGFILE"
systemctl --user restart pulseaudio >> "$LOGFILE" 2>&1
systemctl --user restart pipewire >> "$LOGFILE" 2>&1
sudo alsa force-reload >> "$LOGFILE" 2>&1
echo "Audio services restarted." >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Environment information
echo "8. Environment Information:" >> "$LOGFILE"
echo "Kernel: $(uname -r)" >> "$LOGFILE"
echo "Distribution: $(lsb_release -d | cut -f2-)" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Test sound playback directly via ALSA
echo "9. Testing Sound Playback via ALSA:" >> "$LOGFILE"
echo "Running speaker-test on default device..." >> "$LOGFILE"
speaker-test -D hw:1,0 -c 2 -l 1 >> "$LOGFILE" 2>&1
echo "----------------------------------------" >> "$LOGFILE"

echo "Diagnosis and recovery complete. Log saved to $LOGFILE."
