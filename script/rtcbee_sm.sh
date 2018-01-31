#!/bin/bash

# ---------
#   Usage:
#
#   $ ./rtcbee_sm.sh https://stream-manager.url/streammanager/api/2.0/event/live/todd?action=subscribe live todd 10 10
#
# ---------

DEBUG_PORT_START=9000
endpoint=$1 # stream manager endpoint
context=$2
name=$3
amount=$4
timeout=$5
pids=()

ulimit -n 65536
ulimit -c unlimited
sysctl fs.inotify.max_user_watches=13166604

rm -rf log
mkdir -p log

function checkStatus {
  bee=$1
  debug_port=$((DEBUG_PORT_START + bee))
  log="log/rtcbee_${debug_port}.log"
  pid=${pids[${bee}-1]}

  echo "Check Status on Bee $bee..."

  # if out match /Stream \w+ does not exist/g -> error
  failure=0
  success=0
  regex_fail='Subscribe\.InvalidName'
  regex_success='Subscribe\.Start'

  while read -r line
  do
    if [[ $line =~ $regex_fail ]]; then
      failure=1
    elif [[ $line =~ $regex_success ]]; then
      success=1
    fi
  done < $log

  if [ $failure -eq 1 ]; then
    echo "--- ALERT ---"
    echo "Bee $bee failed in its mission. View ${log} for more details."
    kill -9 "$pid" || echo "Failure to kill ${pid}."
    echo "--- // OVER ---"
  elif [[ $success -eq 1 ]]; then
    echo "--- Success ---"
    echo "Bee $bee has begun attack..."
    (sleep "$timeout"; kill -9 "$pid" || echo "Failure to kill ${pid}.")&
    echo "--- // OVER ---"
  else
    echo "no report yet for $bee..."
    (sleep 2; checkStatus "$bee")&
  fi
}

dt=$(date '+%d/%m/%Y %H:%M:%S')
echo "Starting attack at $dt"

for ((i=1;i<=amount;i++)); do
  debug_port=$((DEBUG_PORT_START + i))
  json=$(curl -X GET -H "Content-type:application/json" "$endpoint")
  output=$(python sm_parser.py "$json")
  echo "output ${output}."
  if [ "$output" -eq "0" ]; then
    echo "--- WARNING ---"
    echo "Bee $i could not be dispatched. ${json}"
    echo "--- // OVER ---"
    continue
  fi
  server_address="$output"
  client_endpoint="http://${server_address}:5080/${context}/viewer.jsp?host=${server_address}&stream=${name}"
#  chromium-browser --single-process --user-data-dir=/tmp/chrome"$(date +%s%N)" --headless --disable-gpu --mute-audio --window-size=1024,768 --remote-debugging-port=$debug_port "$client_endpoint" 3>&1 1>"log/rtcbee_${debug_port}.log" 2>&1 &
  /Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --single-process --user-data-dir=/tmp/chrome"$(date +%s%N)" --headless --disable-gpu --mute-audio --window-size=1024,768 --remote-debugging-port=$debug_port "$client_endpoint" 3>&1 1>"log/rtcbee_${debug_port}.log" 2>&1 &
  pid=$!
  pids[$i-1]=$pid
  echo "Dispatching Bee $i, PID(${pid})..."
  checkStatus $i
  sleep 1
done

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "Attack deployed at $dt"

