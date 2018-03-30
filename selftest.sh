#/bin/bash
if [ -d "bin" ]; then
	rm -rf bin
fi
mkdir bin
cd bin
mkdir ccemu

HOME=$PWD/bin/ccemu	

echo "using Display: $DISPLAY"
flvrec.py -o record.flv -r 60 -P ../vnc-pass.txt localhost$DISPLAY &
THE_PID=$!

# Xvfb :99 -screen 0 1024x768x24 &
# THE_PID=$!
# DISPLAY=:99
sleep 0.5s
love /srv/lua/cclite/1.7/cclite-latest-beta.love &
sleep 1s

xdotool key c d space p r o g r a m s Return
sleep 0.1s

xdotool key x w o s _ s e l f t e s t Return
sleep 1.5s

xdotool key s h u t d o w n Return
sleep 0.5s

kill -4 $THE_PID
