#!/bin/bash

# Diagnose SoundBlaster USB Audio Issues

LOGFILE="/home/akienm/bin/audio_diagnosis.log"

echo "Audio Diagnosis Log - $(date)" > "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check if the USB device is detected
echo "1. USB Devices:" >> "$LOGFILE"
lsusb >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check ALSA device list
echo "2. ALSA Devices:" >> "$LOGFILE"
aplay -l >> "$LOGFILE" 2>&1
arecord -l >> "$LOGFILE" 2>&1
echo "----------------------------------------" >> "$LOGFILE"

# Check PulseAudio sources and sinks
if command -v pactl > /dev/null; then
    echo "3. PulseAudio Sinks and Sources:" >> "$LOGFILE"
    pactl list short sinks >> "$LOGFILE"
    pactl list short sources >> "$LOGFILE"
    echo "----------------------------------------" >> "$LOGFILE"
fi

# Check PipeWire (if installed)
if command -v pw-cli > /dev/null; then
    echo "4. PipeWire Nodes:" >> "$LOGFILE"
    pw-cli dump >> "$LOGFILE" 2>/dev/null
    echo "----------------------------------------" >> "$LOGFILE"
fi

# Check kernel modules
echo "5. Kernel Modules:" >> "$LOGFILE"
lsmod | grep -i snd >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check system logs for relevant errors
echo "6. Recent Kernel Logs:" >> "$LOGFILE"
dmesg | grep -i "usb\|sound\|audio" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

# Check user-specific audio settings
echo "7. User PulseAudio Configuration:" >> "$LOGFILE"
if [ -f ~/.config/pulse/client.conf ]; then
    cat ~/.config/pulse/client.conf >> "$LOGFILE"
else
    echo "No user-specific PulseAudio configuration found." >> "$LOGFILE"
fi
echo "----------------------------------------" >> "$LOGFILE"

# Environment information
echo "8. Environment Information:" >> "$LOGFILE"
echo "Kernel: $(uname -r)" >> "$LOGFILE"
echo "Distribution: $(lsb_release -d | cut -f2-)" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"

echo "Diagnosis complete. Log saved to $LOGFILE."
