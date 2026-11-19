#!/bin/bash
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/Music/ /media/${SUDO_USER:-$USER}/1TBUSBSSD1/Music
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/OneDrive/ /media/${SUDO_USER:-$USER}/1TBUSBSSD1/OneDrive
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/People/ /media/${SUDO_USER:-$USER}/1TBUSBSSD1/People
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/Porn/ /media/${SUDO_USER:-$USER}/1TBUSBSSD1/Porn
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/Video/ /media/${SUDO_USER:-$USER}/1TBUSBSSD1/Music
sudo rsync -aAXv --progress --ignore-existing /media/${SUDO_USER:-$USER}/2TBUSBSSD1/Video/ /media/${SUDO_USER:-$USER}/1TBUSBSSD2/Video

