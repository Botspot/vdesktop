# vdesktop
## Vdesktop runs any RPi operating system inside any RPi operating system. (like a VM)
See it in action:  
![animated screen recording](https://i.ibb.co/Y8gHjz8/vdesktop.gif)  
This script is excellent in these situations:
 - Customizing a new Raspbian image: installing packages, configuring raspi-config, installing Chrome Extensions, changing wallpaper, etc.
 - Migrating to a clean install of Raspbian and want to compare the appearance of both OS'es at once.
 - Run a fresh version of an OS to make a video or to test software compatibility.
 - Running something you might want to undo (such as compiling) and don't want your main OS modified.
 - "Switch" OSes without ever shutting down or swapping SD cards.
 - Running Raspbian Stretch on a Pi 4.

## To download:
```
git clone https://github.com/Botspot/vdesktop
```

## To run:
```
sudo ~/vdesktop/vdesktop
```
After running once, vdesktop will create a file in /usr/bin. So from now on you can simply run `vdesktop`. (with no sudo)  
## Usage:
Boot a .img file: `vdesktop /home/pi/2020-08-20-raspios-buster-armhf.img`  
Boot a usb drive: `vdesktop /dev/sda`  
Boot a directory: `vdesktop /home/pi/raspbian-stretch/`  
A second word specifies the boot mode: `cli`, or `gui`. If none 
specified, **gui mode is assumed**.

## Variable & env file usage:
This new version of vdesktop allows many options to be customized.  
For example, you can prevent vdesktop from logging in automatically to the guest.
```
VDESKTOP_AUTO_LOGIN=no vdesktop /dev/sdc
```
In the above example, the `VDESKTOP_AUTO_LOGIN` value will not be preserved for the next command you run in the terminal. If you want such a behavior, do something like this:
```
export VDESKTOP_AUTO_LOGIN=no
vdesktop /dev/sdc
```
To change a setting permanently, go edit the `settings.env` file.
```
BOOT_MODE=gui
UMOUNT_ON_EXIT=yes
USERNAME=pi
PASSWORD=raspberry
MOUNTPOINT=/media/pi/vdesktop
ENABLE_ROOTMOUNT=yes
#ENABLE_VIRGL=no
#LOCAL_BINARIES=yes
NSPAWN_FLAGS=''
#AUTO_LOGIN=yes
```
Did you notice anything different? None of these variables are prefixed with `VDESKTOP_`. Why not? Well, this allows there to be two variable sets, one of which overrides the other.  
If the env file contains `BOOT_MODE=cli`, but on the terminal you set `VDESKTOP_BOOT_MODE=gui`, which one should `vdesktop` obey? Turns out the "`VDESKTOP_`"-prefixed variable will take priority.

Variable explanation:
 - `BOOT_MODE`
   - Allowed values: `gui` and `cli`
   - Default value: `gui`
   - If `gui`, vdesktop will attempt to launch a graphical desktop session for the booted device.
 - `UMOUNT_ON_EXIT`
   - Allowed values: `yes` and `no`
   - Default value: `yes`
   - When the booted device exits, should vdesktop automatically unmount the device and exit?
 - `USERNAME`
   - Allowed values: *anything*
   - Default value: `pi`
   - Specifies the username vdesktop will attempt to login with.
 - `PASSWORD`
   - Allowed values: *anything*
   - Default value: `raspberry`
   - Specifies the password vdesktop will attempt to login with.
 - `AUTO_LOGIN`
   - Allowed values: `yes` and `no`
   - Default value: `yes`
   - If set to `no`, vdesktop will not attempt to login to the guest.
   - Note: If set to `yes` and the user/pass combination is incorrect, you can login manually afterwards. So there are few cases when you would have to set this to `no`.
 - `MOUNTPOINT`
   - Allowed values: *Any empty directory.*
   - Default value: `/media/pi/vdesktop`
   - Location where vdesktop will mount the device.
   - Note: If value is set to a nonexistent directory, vdesktop will create it.
 - `ENABLE_ROOTMOUNT`
   - Allowed values: `yes` and `no`
   - Default value: `yes`
   - Enables/disables the mounting of files from the `~/vdesktop/rootmount` into the device.
   - Note: This is like a bind-mount into the device. You can add scripts, folders - anything you want into the device - and when vdesktop exits, all those files/folders will be unmounted.
 - `ENABLE_VIRGL`
   - Allowed values: `yes` and `no`
   - Default value: *depends*. If `BOOT_MODE` is set to `gui`, then this default value is `yes`. If `BOOT_MODE` is set to `cli`, then this default value is `no`.
   - Enables/disables the virtual GPU for the device.
   - Note: Enabling this allows much smoother graphics for some applications, but for other applications, it can cause X server issues.
 - `LOCAL_BINARIES`
   - Allowed values: `yes` and `no`
   - Default value: `yes`
   - Enables/disables using the `~/vdesktop/systemd-nspawn-32` or `systemd-nspawn-64` binaries. If set to `no`, vdesktop will use the version of `systemd-nspawn` that exists on your main system.
   - Note: vdesktop uses this later version of `systemd-nspawn` to fix several CPU bugs. Using an outdated `systemd-nspawn` was the cause for all the Firefox crashes and Chromium "Aw, Snap!"s
 - `NSPAWN_FLAGS`
   - Allowed values: *anything*
   - Default value: *nothing*
   - Easily add your own flags to `systemd-nspawn`, either to change some behavior or to add a bind-mount.

## How does it work?
Vdesktop uses a `systemd-nspawn` container to 'boot' its devices with. This is very similar to a `chroot`.  
[Systemd-nspawn](https://www.man7.org/linux/man-pages/man5/systemd.nspawn.5.html) is much faster than other methods because it doesn't use any emulation. Why would you need emulation anyway, when you want a Pi to run its own OS?  
Try out systemd-nspawn yourself:
```
sudo systemd-nsapwn -bD /media/pi/USB-DRIVE
```
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
This is even harder. Launch Xephyr from a host's terminal, then connect to it from within the guest.

From a terminal running on the host system:

    Xehpyr :1

A black window will appear. Assuming you've already ran the necessary `systemd-nspawn` command and logged in as user pi, to make the container/guest system connect to the Xephyr window, run this in the guest's console:

    export DISPLAY=:1
    /usr/bin/startlxde-pi

If the graphics look bad, you will have to restart certain services. From within the guest's console:

    eval "pcmanfm --desktop --profile LXDE-pi; sleep 20; pcmanfm --desktop --profile LXDE-pi" &
    lxpanelctl restart
    sleep 10
    lxpanelctl restart

#### What if you want everything to work automatically, without requiring any user interaction?
This is too long to post here. After all, it takes the entire vdesktop script to do this.
Here's what it does:

 - `expect` logs in automatically to the console. It types in `pi` and `raspberry` so you don't have to.
 - After logging in, `/etc/profile` is run. Vdesktop mounts a custom version of `/etc/profile` to autostart an X session from the inside. It creates a signal file: `/xready`, to let vdesktop know the gui is ready to be loaded.
 - `Xephyr` launches when that that file is created, (this is the VNC-style window), to allow the container's X session to connect to it.
 - Once Xephyr opens and the desktop loads, `clipboardsync` runs, to let you copy & paste text back and forth.
 - When you exit the container, and all of the above has to be safely dismantled and shutdown. Complex? You bet.
 - On top of all that, `vdesktop` ensures dependencies are installed, detects filesystem errors in the .img and asks permission to repair them, and performs a host of little bug fixes to make it Just Work™.

## Directory Tree:
 - `vdesktop/` The main vdesktop folder. Located at /home/pi by default.
   - `clipboardsync` Short script keeps the guest's and host's clipboards in sync, like VNC.
   - `COPYING` Stores the GNU General Public license v3 for `vdesktop`.
   - `nspawn` The systemd-nspawn command. This was broken out of `vdesktop` to allow many bind-mounts.
   - `profile` This is temporarily mounted to the selected device to start the desktop session. (If enabled via Settings)
   - `README.md` You're reading this right now.
   - `settings.env` This is the ENV file to store permanent setting changes.
   - `systemd-nspawn-32` 32-bit `systemd-nspawn` binary.
   - `systemd-nspawn-64` 64-bit `systemd-nspawn` binary.
   - `vdesktop` The main script
   - `vdesktop-runner` Short script that's put in /usr/local/bin. You can now run `vdesktop` in a terminal, instead of `sudo /home/pi/vdesktop/vdesktop`.
   - `version` Lets Vdesktop keep track of what version it is to see when an update is available.
   - `rootmount/` Files contained in this directory are mounted to the guest's filesystem before boot, and unmounted after boot.
   - `src/` This directory holds `libsystemd-shared-246.so`, necessary for the `systemd-nspawn` binaries to work.

## To do:
 - [X] Write up a more comprehensive set of instructions, and add come CLI flags.
 - [X] autologin to the guest, so the user doesn't have to do it manually.
 - [X] auto-detect default desktop session profile to correctly boot pi-top OS and Raspbian that doesn't have raspberrypi-ui-mods installed.
 - [X] Sync **sound** between host and guest, while avoiding pulseaudio.
 - [X] Sync **clipboards** between host and guest.
 - [X] display text at guest's default size instead of autoscaling to Xephyr's aspect ratio.
 - [X] display guest's default mouse pointer instead of the fallback Adwaita.
