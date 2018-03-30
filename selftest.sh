#/bin/bash
if [ -d "bin" ]; then
	rm -rf bin
fi
mkdir bin
cd bin

if [ -d "/var/lib/jenkins/.local/share/love/ccemu/data/0" ]; then
	rm -rf "/var/lib/jenkins/.local/share/love/ccemu/data/0"
fi
mkdir "/var/lib/jenkins/.local/share/love/ccemu/data/0"
cp -r "../src/assets/computercraft/lua/rom" "/var/lib/jenkins/.local/share/love/ccemu/data/0"

echo "using Display: $DISPLAY"
flvrec.py -o record.flv -P ../vnc-pass.txt localhost$DISPLAY &
THE_PID=$!

# Xvfb :99 -screen 0 1024x768x24 &
# THE_PID=$!
# DISPLAY=:99
sleep 1s
love /srv/lua/cclite/1.7/cclite-latest-beta.love &
sleep 5s

xdotool key c d space p r o g r a m s Return
sleep 2s

xdotool key x w o s underscore s e l f t e s t Return
sleep 10s

xdotool key s h u t d o w n Return
sleep 2s

kill -4 $THE_PID
