#!/bin/bash

# Output file
TMPFILE=$(mktemp)

echo "=== PulseAudio Process Check ===" >> $TMPFILE
ps aux | grep pulseaudio | grep -v grep >> $TMPFILE

echo -e "\n=== PulseAudio Socket Status ===" >> $TMPFILE
ls -l ~/.config/pulse/ 2>/dev/null >> $TMPFILE
ls -l /run/user/$UID/pulse/ 2>/dev/null >> $TMPFILE

echo -e "\n=== Trying to start PulseAudio ===" >> $TMPFILE
pulseaudio --start >> $TMPFILE 2>&1
sleep 2

echo -e "\n=== PulseAudio Status After Start ===" >> $TMPFILE
pulseaudio --check >> $TMPFILE 2>&1
ps aux | grep pulseaudio | grep -v grep >> $TMPFILE

echo -e "\n=== PulseAudio Configuration ===" >> $TMPFILE
ls -l ~/.config/pulse/daemon.conf 2>/dev/null >> $TMPFILE
if [ -f ~/.config/pulse/daemon.conf ]; then
    echo "=== Daemon Config Contents ===" >> $TMPFILE
    cat ~/.config/pulse/daemon.conf >> $TMPFILE
fi

echo -e "\n=== System PulseAudio Status ===" >> $TMPFILE
systemctl --user status pulseaudio >> $TMPFILE 2>&1

# Output everything with base64 encoding
base64 $TMPFILE

# Cleanup
rm $TMPFILE
