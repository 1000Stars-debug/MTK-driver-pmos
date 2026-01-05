#!/bin/sh

# Driver belongs to Mediatek
if [ $(id -u) -ne 0 ]; then
  echo "FAILED: Please run as root (doas or sudo)"
  exit 1
fi

echo "********MEDIATEK PROPRIETORY********"
echo "Extracting package..."
sleep 2s

# 1. Prepare Temp Space
[ -d /tmp/mtk_temp ] && rm -rf /tmp/mtk_temp
mkdir -p /tmp/mtk_temp || { echo "FAILED: Could not create temp dir"; exit 1; }

# 2. Extraction with Error Catching
ARCHIVE_LINE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0")
tail -n+$ARCHIVE_LINE "$0" | tar -xz -C /tmp/mtk_temp 2>/dev/null

if [ $? -ne 0 ]; then
    echo "FAILED: Extraction failed (Invalid tar header). Rebuild the .run file!"
    exit 1
fi

# 3. Check if source folder exists after extraction
if [ ! -d "/tmp/mtk_temp/driver_src" ]; then
    echo "FAILED: driver_src not found in archive."
    exit 1
fi

cd /tmp/mtk_temp/driver_src/ || { echo "FAILED: Could not enter source dir"; exit 1; }

# 4. Copy Files and Services
mkdir -p /etc/local.d
cp accelerometer_start/accel.start /etc/local.d/ 2>/dev/null
cp audio/audio.start /etc/local.d/ 2>/dev/null
cp chiploader/wifi.start /etc/local.d/ 2>/dev/null

# Fix permissions only if files were actually copied
if ls /etc/local.d/*.start >/dev/null 2>&1; then
    chmod +x /etc/local.d/*.start
fi

# 5. User Configs (MPV)
REAL_USER=$(logname || echo $USER)
USER_HOME="/home/$REAL_USER"
if [ -d "$USER_HOME" ]; then
    mkdir -p "$USER_HOME/.config/mpv"
    cp audio/mpv.conf "$USER_HOME/.config/mpv/" 2>/dev/null
    chown -R "$REAL_USER":"$REAL_USER" "$USER_HOME/.config/mpv"
fi

# 6. Binaries
mkdir -p /usr/local/bin
cp audio/youtube_music.sh /usr/local/bin/ 2>/dev/null
cp -r chiploader/bin/* /usr/local/bin/ 2>/dev/null
if ls /usr/local/bin/* >/dev/null 2>&1; then
    chmod +x /usr/local/bin/*
fi

# 7. System & Firmware
mkdir -p /system
cp -r system/* /system/ 2>/dev/null

mkdir -p /etc/firmware
mkdir -p /etc/fmr

echo "Creating firmware links..."
ln -sf /system/etc/firmware/* /etc/firmware/ 2>/dev/null
ln -sf /system/etc/fmr/* /etc/fmr/ 2>/dev/null

echo "------------------------------------"
echo "Drivers Installed successfully!"
exit 0

__ARCHIVE_BELOW__
