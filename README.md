# vdesktop
## Run a second instance of Raspbian inside Raspbian. 
![animated screen recording](https://i.ibb.co/Y8gHjz8/vdesktop.gif)  
This script is excellent in these situations:
 - Customizing a new Raspbian image - installing packages, configuring raspi-config, changing wallpaper, etc.
 - Migrating to a clean install of Raspbian and want to compare the appearance of both OS'es at once.
 - Running two versions of software at the same time, one in the host, other in the guest.
 - Running something you might want to undo (such as compiling) and don't want your main OS modified.
 - "Switch" OSes without ever shutting down or swapping SD cards.
 - Running Raspbian Stretch on a Pi 4.

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

## How does it work?
Vdesktop uses a systemd-nspawn container to 'boot' its devices with. This is similar to a chroot.  
[Systemd-nspawn](https://www.man7.org/linux/man-pages/man5/systemd.nspawn.5.html) is much faster than other methods because it doesn't use any emulation. Why would you need emulation anyway, when you want a Pi to run its own OS?  
Try out systemd-nspawn yourself:

    sudo systemd-nsapwn -bD /media/pi/USB-DRIVE

(Where /media/pi/USB-DRIVE is the path to an externally connected usb device with Raspberry Pi OS flashed to it.)  
With that command, you'll see the SD card boot up. After manually logging in yourself, you can change settings, run updates, etc, *as long as it can be done in the command-line*.
#### What about an image file?
This is harder to do, since it involves mounting the img first, but here you go:

    sudo -i
    LOOP="$(losetup -fP --show /path/to/your-raspbian.img)"
    mount -o rw "${LOOP}p2" /media/pi/vdesktop
    mount -o rw "${LOOP}p1" /media/pi/vdesktop/boot
    systemd-nspawn -bD /media/pi/vdesktop
    umount -fl /media/pi/vdesktop/boot
    umount -fl /media/pi/vdesktop
    losetup -d "$LOOP"
#### What if you want graphics?
This is *really hard*, and too long to post here. But here's what it involves:

 - A custom password file is mounted to the container to make sure the user pi's password is always `raspberry`.
 - `expect` logs in automatically to the console. It types in `pi` and `raspberry` so you don't have to.
 - After logging in, `/etc/profile` is run. Vdesktop mounted a custom version of that too, to start an X session from the inside.
 - Meanwhile, a loop is running 100 times per second in the host, waiting until the container runs `lxsession`.
 - `Xephyr` opens when that loop triggers, (this is the VNC-style window), to allow the container's `lxsession` to connect to it.
 - Once Xephyr opens and the desktop loads, `clipboardsync` runs, to let you copy & paste text back and forth.
 - When you exit the container, and all of the above has to be safely dismantled and shutdown. Complex? You bet.

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
