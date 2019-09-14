# vdesktop
Run a second instance of Raspbian inside Raspbian. 

To install/update:  
`git clone https://github.com/Botspot/vdesktop`

To run:  
`sudo /home/pi/vdesktop/vdesktop`

Usage:  
Boot from an image file:              `sudo vdesktop /home/pi/Downloads/2018-07-09-pi-topOS.img`  
Or a block device:                    `sudo vdesktop /dev/sda`  
Or the root directory of the guest:   `sudo vdesktop /home/pi/raspbian-stretch/`  

Once the container has booted, you have to log in with the guest's credentials. Then the guest's GUI will display in the Xephyr window.
