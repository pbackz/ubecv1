#!/bin/bash

# turn on bash's job control
set -m

# Start the primary process and put it in the background
./main &

# Start the helper process
echo 'toto $i' > /tmp/testy

fg

