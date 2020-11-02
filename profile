# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "`id -u`" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games"
fi
export PATH

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi



#Vdesktop modifications:

if [ -S /tmp/.virgl_test ];then
  export LIBGL_ALWAYS_SOFTWARE=1
  export GALLIUM_DRIVER=virpipe
  export MESA_EXTENSION_OVERRIDE=-GL_MESA_framebuffer_flip_y
fi
#only run anything if display var is empty. Allows terminals to open like normal.
if [ -z $DISPLAY ];then
  export DISPLAY=:1
  
  #when this file is created in guest, Xephyr is launched from host.
  sudo bash -c "echo '' > /xready"
  sleep 2
  
  
  if [ -f /usr/bin/startxfce4 ];then
    #if OS is twisterOS, kali, or other xfce4 desktop
    
    eval "for n in {1..5}; do
      #if startxfce4 fails the first time, try again up to 5 times
      (/usr/bin/startxfce4 &>/dev/null 2>&1) &>/dev/null &
      sleep 2
    done" &>/dev/null &
    
    sleep 5
    xfwm4 --replace &>/dev/null &
    sleep 5
    xfwm4 --replace &>/dev/null &
  else
    
    #os is not twisteros so try lxsession instead
    eval "for n in {1..5}; do
      #if startlxde fails the first time, try again up to 5 times
      (/usr/bin/startlxde-pi &>/dev/null 2>&1) &>/dev/null &
      sleep 2
    done" &>/dev/null &
    
    sleep 5
    eval "
      killall pcmanfm &>/dev/null
      sleep 1
      pcmanfm --desktop --profile=LXDE-pi &>/dev/null &
      sleep 2
      openbox --restart &>/dev/null
      sleep 2
      lxpanelctl restart &>/dev/null
      sleep 1
    " &>/dev/null &
  fi
fi
export DISPLAY=:1
systemctl --user stop pulseaudio.socket &>/dev/null &

