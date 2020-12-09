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
  #export GALLIUM_DRIVER=llvmpipe
  export MESA_EXTENSION_OVERRIDE=-GL_MESA_framebuffer_flip_y
fi

export QT_X11_NO_MITSHM=1
export _X11_NO_MITSHM=1
export _MITSHM=0

#only run anything if display var is empty. Allows terminals to open like normal.
if [ -z $DISPLAY ];then
  export DISPLAY=:1
  
  #when this file is created in guest, Xephyr is launched from host.
  sudo bash -c "echo '' > /xready"
  sleep 2
  sudo update-icon-caches /usr/share/icons/*
  #refresh the desktop session once
  (for n in {1..1}; do
    x-session-manager &>/dev/null &
    pid=$!
    sleep 5
    pkill $pid xfwm4 pcmanfm lxpanel
  done
  x-session-manager &>/dev/null &) &>/dev/null &
fi
export DISPLAY=:1

