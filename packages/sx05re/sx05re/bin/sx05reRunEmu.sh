#!/bin/sh

hdmimode=`cat /sys/class/display/mode`;

# Set framebuffer geometry to match the resolution, splash should change according to the resolution. 
case $hdmimode in
  480*)            X=720  Y=480  SPLASH="/storage/.config/splash/splash-1080.png" ;;
  576*)            X=720  Y=576  SPLASH="/storage/.config/splash/splash-1080.png" ;;
  720p*)           X=1280 Y=720  SPLASH="/storage/.config/splash/splash-1080.png" ;;
  *)               X=1920 Y=1080 SPLASH="/storage/.config/splash/splash-1080.png" ;;
esac

# Set BPP to 16, Most RetroArch shaders work best and PPSSPPSDL ONLY runs at 16bpp, we might need to set this in autorun.sh and set it to 32bpp when we run Kodi as it is now it generates an annoying flicker when the switch.
# BPP="16"
   
# Set the variables
CFG="/storage/.emulationstation/es_settings.cfg"
SX05RELOG="/storage/sx05re.log"
PAT="s|\s*<string name=\"Sx05RE_$1_CORE\" value=\"\(.*\)\" />|\1|p"
EMU=$(sed -n "$PAT" "$CFG")

# Clear the log file
echo "Sx05RE Run Log" > $SX05RELOG

# Default run command
RUNTHIS='/usr/bin/retroarch -L /tmp/cores/${EMU}_libretro.so "$2"'

# Read the first argument to see if its REICAST, MAME or PSP
case $1 in
"REICAST")
   RUNTHIS='/usr/bin/reicast.sh "$2"'
         ;;
"ADVMAME")
   RUNTHIS='/usr/bin/advmame.sh "$2"'
         ;;
"PSP")
      if [ "$EMU" = "PPSSPPSA" ]; then
   #PPSSPP can run at 32BPP but only with buffered rendering, some games need non-buffered and the only way they work is if I set it to 16BPP
   /usr/bin/setres.sh 16
   RUNTHIS='/usr/bin/ppsspp.sh "$2"'
      fi
        ;;
esac


# Splash screen, not sure if this is the best way to do it, but it works so far, but not as good as I want it too with PPSSPPSDL and advmame :(
(
  fbi $SPLASH -noverbose > /dev/null 2>&1
)&

# Write the command to the log file.
echo "First parameter: $1" >> $SX05RELOG 
echo "Second Parameter: $2" >> $SX05RELOG 
echo "Run Command is:" >> $SX05RELOG 
eval echo  ${RUNTHIS} >> $SX05RELOG 

# Exceute the command and try to output the results to the log file if it was not dissabled.
if [ -z "$3" ]; then
   echo "Emulator Output is:" >> $SX05RELOG
   eval ${RUNTHIS} >> $SX05RELOG 2>&1
 else 
   echo "Emulator log was dissabled" >> $SX05RELOG
   eval ${RUNTHIS}
fi 

# Return to default mode
/usr/bin/setres.sh
