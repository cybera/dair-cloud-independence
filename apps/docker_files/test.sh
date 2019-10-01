#!/bin/bash
# This script will check if our docker application is online
# It will check 60ish times, and if it is still offline fail
x=1
while :
do
  if curl http://172.17.0.1/polls/
  then
    echo Up and running
    break
  else
    echo Still waiting loop $x / 60
    sleep 10
  fi
  if [ $x -gt 59 ]; then
    echo Timeout
    cd apps/docker_files
    /usr/local/bin/docker-compose down
    break
  fi
  x=`expr $x + 1`
done
sleep 5
