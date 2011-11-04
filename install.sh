#!/bin/bash

# Needs root to execute
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

install -b -m 755 ag.sh /usr/bin/ag
