# vdesktop
## Run a second instance of Raspbian inside Raspbian. 
![screenshot of Stretch running in buster](https://i.ibb.co/0yhP6sg/container-desktop-min.png)  
This script is excellent in these situations:
 - Customizing a new Raspbian image - installing packages, configuring raspi-config, changing wallpaper, etc.
 - Migrating to a clean install of Raspbian and want to compare the appearance of both OS'es at once.
 - Running two versions of software at the same time, one in the host, other in the guest.
 - Running something you might want to undo (such as compiling) and don't want your main OS modified.
 - "Switch" OSes without ever shutting down or swapping SD cards.
 - Running Raspbian Stretch on a Pi 4.

## Download the [disk image](https://drive.google.com/file/d/1cJbcNDnm4Zm8zeHlCp8JQT5pwacAZeCp/view?usp=sharing)
Ships with vdesktop installed, and a handy menu shortcut to boot a pre-downloaded Stretch img file.

## To download & make excecutable:  
`git clone https://github.com/Botspot/vdesktop`  

## To run:  
`sudo ~/vdesktop/vdesktop`

## Usage:  
Boot from an image file:    `sudo ~/vdesktop/vdesktop /home/pi/2019-09-26-raspbian-buster.img`  
Or a block device:          `sudo ~/vdesktop/vdesktop /dev/sda`  
Or the guest's directory:   `sudo ~/vdesktop/vdesktop /home/pi/raspbian-stretch/`  
A second word specifies the boot mode: `cli`, `cli-login`, and `gui`. If none 
specified, cli mode is assumed.

Once the container has booted, you have to log in with the guest's credentials. Then the guest's GUI will display in the Xephyr window.

## Directory Tree:
 - vdesktop/ - The main vdesktop folder. Located at /home/pi by default.
   - vdesktop - The main script
   - clipboardsync - Keeps the guest's and host's clipboards in sync, like VNC.
   - nspawn - The systemd-nspawn command. This was broken out of `vdesktop` to allow for lots of bind-mounts. (for sound sync)
   - profile - This is temporarily mounted to the selected device to start the desktop session. (If enabled via Settings)
   - shadow - This is mounted to /etc/shadow of the selected device to ensure the user pi's password is raspberry.
   - version - Lets Vdesktop keep track of what version it is to see when an update is available.
   - README.md - You're reading this right now.

## To do:
 - [X] Write up a more comprehensive set of instructions, and add come CLI flags.
**Check!** CLI flags choose what boot mode, and instructions are in the form of the [Pi Power Tools](https://github.com/Botspot/Pi-Power-Tools) GUI app.
 - [X] autologin to the guest, so the user doesn't have to do it manually.
 - [ ] auto-detect default desktop session profile to correctly boot pi-top OS and Raspbian that doesn't have raspberrypi-ui-mods installed.
 - [X] Sync **sound** between host and guest, while avoiding pulseaudio.
 - [X] Sync **clipboards** between host and guest.
 - [ ] display text at guest's default size instead of autoscaling to Xephyr's aspect ratio.
 - [X] display guest's default mouse pointer instead of the fallback Adwaita.
