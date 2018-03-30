#/bin/bash
if [ -d "bin" ]; then
	rm -rf bin
fi
mkdir bin
cd bin
mkdir ccemu

HOME=$PWD/bin/ccemu	

Xvfb :99 -screen 0 1024x768x24 &
THE_PID=$!
DISPLAY=:99
sleep 0.5s
love /srv/lua/cclite/1.7/cclite-latest-beta.love &
import -window root screenshot_001.png
sleep 1s
import -window root screenshot_002.png

xdotool key c
xdotool key d
xdotool key Space
xdotool key p
xdotool key r
xdotool key o
xdotool key g
xdotool key r
xdotool key a
xdotool key m
xdotool key s
xdotool key RETURN
import -window root screenshot_010.png
sleep 0.1s
import -window root screenshot_011.png

xdotool key x
xdotool key w
xdotool key o
xdotool key s
xdotool key _
xdotool key s
xdotool key e
xdotool key l
xdotool key f
xdotool key t
xdotool key e
xdotool key s
xdotool key t
xdotool key RETURN
import -window root screenshot_100.png
sleep 0.1s
import -window root screenshot_101.png
sleep 0.1s
import -window root screenshot_102.png
sleep 0.1s
import -window root screenshot_103.png
sleep 0.1s
import -window root screenshot_104.png
sleep 0.1s
import -window root screenshot_105.png
sleep 0.1s
import -window root screenshot_106.png
sleep 0.3s
import -window root screenshot_107.png
sleep 0.3s
import -window root screenshot_108.png
sleep 0.3s
import -window root screenshot_109.png
sleep 0.3s
import -window root screenshot_110.png

xdotool key s
xdotool key h
xdotool key u
xdotool key t
xdotool key d
xdotool key o
xdotool key w
xdotool key n
xdotool key RETURN
import -window root screenshot_200.png
sleep 0.3s
import -window root screenshot_201.png
sleep 0.3s
import -window root screenshot_202.png

kill -15 $THE_PID
