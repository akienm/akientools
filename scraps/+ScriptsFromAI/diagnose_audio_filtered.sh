#!/bin/bash

# Diagnose SoundBlaster USB Audio Issues - Filtered Version

LOGFILE="/home/akienm/bin/audio_diagnosis_filtered.log"

echo "Audio Diagnosis Log - $(date)" > "$LOGFILE"
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

# Check PulseAudio sources and sinks
if command -v pactl > /dev/null; then
    echo "3. PulseAudio Sinks and Sources (Filtered):" >> "$LOGFILE"
    pactl list short sinks | grep -i "soundblaster\|creative" >> "$LOGFILE"
    pactl list short sources | grep -i "soundblaster\|creative" >> "$LOGFILE"
    if [ $? -ne 0 ]; then
        echo "No SoundBlaster sink or source found in PulseAudio." >> "$LOGFILE"
    fi
    echo "----------------------------------------" >> "$LOGFILE"
fi

# Check PipeWire nodes (if installed)
if command -v pw-cli > /dev/null; then
    echo "4. PipeWire Nodes (Filtered for SoundBlaster):" >> "$LOGFILE"
    pw-cli dump | grep -i "soundblaster\|creative" >> "$LOGFILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "No SoundBlaster node found in PipeWire." >> "$LOGFILE"
    fi
    echo "----------------------------------------" >> "$LOGFILE"
fi

# Check kernel modules for SoundBlaster drivers
echo "5. Kernel Modules (Relevant to Sound):" >> "$LOGFILE"
lsmod | grep -i "snd\|usb_audio" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check recent kernel logs for USB or audio-related errors
echo "6. Recent Kernel Logs (Filtered for USB/Audio):" >> "$LOGFILE"
dmesg | grep -i "usb\|audio\|sound" | tail -n 50 >> "$LOGFILE"
if [ $? -ne 0 ]; then
    echo "No relevant USB or audio errors in kernel logs." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Environment information
echo "7. Environment Information:" >> "$LOGFILE"
echo "Kernel: $(uname -r)" >> "$LOGFILE"
echo "Distribution: $(lsb_release -d | cut -f2-)" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

echo "Filtered diagnosis complete. Log saved to $LOGFILE."
