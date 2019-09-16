# vdesktop
Run a second instance of Raspbian inside Raspbian. 

This script is excellent in these situations:
 - Migrating to a clean install of Raspbian and want to copy files from the old one.
 - Running two versions of software at the same time, one in the host, other in the guest.
 - Running something potentially dangerous (such as compiling) but don't want your main OS unmodified.
 - "Switch" OSes without ever shutting down or swapping SD cards.
 - Run Raspbian Stretch on a Pi 4.

To download & make excecutable:  
`git clone https://github.com/Botspot/vdesktop`  
`chmod +x /home/pi/vdesktop/rc.local /home/pi/vdesktop/vdesktop`

To run:  
`sudo ~/vdesktop/vdesktop`

Usage:  
Boot from an image file:    `sudo ~/vdesktop/vdesktop /home/pi/Downloads/2018-07-09-pi-topOS.img`  
Or a block device:          `sudo ~/vdesktop/vdesktop /dev/sda`  
Or the guest's directory:   `sudo ~/vdesktop/vdesktop /home/pi/raspbian-stretch/`  

Once the container has booted, you have to log in with the guest's credentials. Then the guest's GUI will display in the Xephyr window.

To do:
 - Write up a more comprehensive set of instructions, and add come CLI flags.
 - autologin to the guest, so the user doesn't have to do it manually.
 - auto-detect default desktop session profile to correctly boot pi-top OS and Raspbian that doesn't have raspberrypi-ui-mods installed.
 - Sync sound between host and guest, preferably avoiding pulseaudio.
 - display text at guest's default size instead of autoscaling to Xephyr's aspect ratio.
 - display guest's default mouse pointer instead of the fall-back Adwaita.
