#!/bin/bash

set +x
set -e

# Based on https://stackoverflow.com/questions/26082444/how-to-work-around-travis-cis-4mb-output-limit
# Works around 4MB Travis log limit

export PING_SLEEP=30s
export WORKDIR="$( cd "$( dirname "$0" )" && pwd )"
export BUILD_OUTPUT=$WORKDIR/build.out

touch $BUILD_OUTPUT

dump_output() {
   echo Tailing the last 500 lines of output:
   tail -500 $BUILD_OUTPUT  
}
error_handler() {
  local loop_pid=$1
  echo ERROR: An error was encountered with the build.
  dump_output
  kill $loop_pid
  exit 1
}

# Set up a repeating loop to send some output to Travis.

bash -c "while true; do echo -e \$(date -u)\n$(tail -n2 $BUILD_OUTPUT)\n; sleep $PING_SLEEP; done" &
PING_LOOP_PID=$!

# If an error occurs, run our error handler to output a tail of the build
trap "error_handler ${PING_LOOP_PID}" EXIT


docker build -f Dockerfile -t thedoh/musl-cross:$TRAVIS_COMMIT . >> $BUILD_OUTPUT 2>&1

dump_output

kill $PING_LOOP_PID
