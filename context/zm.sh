#!/bin/bash
set -e

# Migrate database
/usr/bin/zmupdate.pl

# Start zoneminder
/usr/bin/zmpkg.pl start

function on_term {
  echo 'Shutting down...'
  /usr/bin/zmpkg.pl stop || true
  echo 'Bye!'
}

# Stop zoneminder on exit
trap 'on_term' SIGINT SIGTERM EXIT

# Monitor zoneminder process
while sleep 3; do
  pgrep -F /run/zm/zm.pid &>/dev/null
done
