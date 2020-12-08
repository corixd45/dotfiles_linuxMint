#!/bin/bash

# Record screen and audio with ffmpeg
# lu0

# list recording devices:
# pacmd list-sources|awk '/index:/ {print $0}; /name:/ {print $0}; /device\.description/ {print $0}'

if pgrep ffmpeg
then
    notify-send -i "emblem-videos-symbolic" "Screencast" "Saved" 
    sleep 3 && pkill ffmpeg
else
    if zenity --question --text "Screencast" --ok-label="Start" --cancel-label="Cancel"
    then
        # Wait for dialog
        sleep 1 &&

        # Set name according to date and time
        mkdir -p $HOME/videos/screencast/
        NAME=("$HOME/videos/screencast/sc-$(date +%y%m%d)-$(date +%H%M%S).mp4")

        # Get display resolution
        RES=$(xdpyinfo | grep dimensions | awk '{print $2}')
        
        # Start recording. Codecs chosen according to compatibility with android
        # ffmpeg -y -f x11grab -s $RES -r 30 -i :0.0 -f alsa -i pulse -c:v h264 -c:a aac -ac 2 -vf scale=out_color_matrix=bt709 -pix_fmt yuv420p -movflags faststart $NAME

        INT_MICROPHONE='alsa_input.pci-0000_00_1f.3.analog-stereo'
        BT_HEADSET_SONY='bluez_sink.00_18_09_2E_74_B5.a2dp_sink.monitor'
        BT_HEADSET_TT='bluez_sink.E8_07_BF_31_54_2C.a2dp_sink.monitor'
        HDMI='alsa_output.pci-0000_00_1f.3.hdmi-stereo.monitor'

        ffmpeg -y \
        -f x11grab -video_size 1920x1080 -grab_y 1080 -i :0.0 \
        -f pulse -i $INT_MICROPHONE \
        -f pulse -i $BT_HEADSET_TT \
        -filter_complex \
        "[1:a]volume=0.2[mic]; [2:a]volume=30.0[bt]; \
        [mic][bt]amix=inputs=2[a]" \
         -c:v h264 -vf scale=out_color_matrix=bt709 -pix_fmt yuv420p \
         -movflags faststart \
         -r 30 \
        -map 0:v -map "[a]" -c:a aac $NAME

        # ffmpeg -y \
        # -f x11grab -s $RES \
        # -i :0.0 \
        # -f alsa \
        # -i pulse \
        # -filter:a "volume=4.0" \
        # -c:v h264 -vf scale=out_color_matrix=bt709 -pix_fmt yuv420p \
        # -movflags faststart \
        # -r 30 \
        # -c:a aac -ac 2 $NAME

    fi
fi
