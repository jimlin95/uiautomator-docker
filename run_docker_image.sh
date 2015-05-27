#!/bin/bash
#run docker
docker run --name uiautomator --privileged -e DISPLAY=$DISPLAY -v /dev/bus/usb:/dev/bus/usb -v /tmp/.X11-unix:/tmp/.X11-unix -v /etc/localtime:/etc/localtime:ro -v /home/jim/work/uiautomator:/src -d -p 2222:22 jimlin95/uiautomator 
