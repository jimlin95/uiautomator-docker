#!/bin/bash
#run docker
docker run --name uiautomator-sdk --privileged -v /dev/bus/usb:/dev/bus/usb -v /tmp/.X11-unix:/tmp/.X11-unix -v /home/jim/work/uiautomator:/src -ti -p 2222:22 jimlin95/uiautomator 
