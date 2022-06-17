#!/bin/bash
if [ $PASSWD ] ; then
    echo "root:$PASSWD" | chpasswd
   echo $PASSWD | vncpasswd -f > /root/.vnc/passwd
fi
vncserver -kill :0
rm -rfv /tmp/.X*-lock /tmp/.X11-unix
vncserver :0 -geometry $SIZE
/root/noVNC/utils/novnc_proxy --vnc localhost:5900