#!/bin/sh
exec xfce4-screenshooter --region --mouse --save /dev/stdout | xclip -i -selection clipboard -t image/png
