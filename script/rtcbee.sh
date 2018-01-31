#!/bin/bash

DEBUG_PORT_START=9000
endpoint=$1
amount=$2
timeout=$3
debug_port=$DEBUG_PORT_START
pids=()

ulimit -n 65536
ulimit -c unlimited
sysctl fs.inotify.max_user_watches=13166604

mkdir -p log

dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Starting attack, $dt"

for ((i=1;i<=$amount;i++)); do
  debug_port=$((debug_port + 1))
  echo "Dispatching Bee $i..."
#  chromium-browser --single-process --user-data-dir=/tmp/chrome$(date +%s%N) --headless --disable-gpu --mute-audio --window-size=1024,768 --remote-debugging-port=$debug_port $endpoint >&1 | grep CONSOLE > "logs/rtcbee_${debug_port}.log" &
  /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --single-process --user-data-dir=/tmp/chrome$(date +%s%N) --headless --disable-gpu --mute-audio --window-size=1024,768 --remote-debugging-port=$debug_port $endpoint 3>&1 1>"log/rtcbee_${debug_port}.log" 2>&1 &
  pid=$(echo $!)
  pids[$i-1]=$pid
  echo "PID filed as: ${pid}."
  sleep 1
done

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "Attack deployed, $dt"
# echo $pids

sleep 5
debug_port=$DEBUG_PORT_START

for ((i=1;i<=$amount;i++)); do
  debug_port=$((debug_port + 1))
  log="log/rtcbee_${debug_port}.log"

  # if out match /Stream \w+ does not exist/g -> error
  failure=0
  success=0
  regex_fail='Subscribe\.InvalidName'
  regex_success='Subscribe\.Start'

  while read line
  do
    if [[ $line =~ $regex_fail ]]; then
      failure=1
    elif [[ $line =~ $regex_success ]]; then
      success=1
    fi
  done < $log

  if [ $failure -eq 1 ]; then
    echo "--- ALERT ---"
    echo "Bee $i failed in its mission. View ${log} for more details."
    echo "--- // OVER ---"
  elif [[ $success -eq 1 ]]; then
    echo "--- Success ---"
    echo "Bee $i has begin attack..."
    echo "--- // OVER ---"
  fi

  pid=${pids[${i}-1]}
  echo "Killing PID: ${pid}."
  kill -9 $pid
done

