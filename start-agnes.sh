#!/bin/bash
# Starts the live Agnes interface. Ctrl-C to stop.
cd "$(dirname "$0")"
python3 -m http.server 8899 >/dev/null 2>&1 &
sleep 1
open "http://localhost:8899/agnes-live.html"
echo "Agnes is running at http://localhost:8899/agnes-live.html"
echo "Press Ctrl-C to stop."
wait
