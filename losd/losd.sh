#!/usr/bin/env bash

# Linux OS Detector (LOSD) Bash Script
# Description: To provide a universal Linux OS Versions detector for consistent apples to apples os independent comparision using native tool.
# Verson: 1.0.0
# Version_Date: 2024-03-22
# Author: John Haverlack (jehaverlack@alaska.edu)
# License: MIT (Proposed/Pending) / UAF Only
# Source: https://github.com/acep-uaf/seal-os-lnx

# Check if dependancy binaries are installed.
# List of required binaries: sed, awk, grep
req_binaries=(awk cat cut date df egrep grep lsblk mount sed stat tail tr uname uptime wc which)
for i in "${req_binaries[@]}"; do
  if ! which $i > /dev/null 2>&1; then
    echo "Error: $i binary not found or not executable."
    exit 1
  fi
done

# Determine the directory full path where this losd.sh file is located.
# This is used to source the losd-lib.sh file.
rundir=$(realpath $(dirname $0))

# Check to see if the losd-lib.sh file exists and is readable.
if [ ! -r $rundir/losd-lib.sh ]; then
  echo "Error: $rundir/losd-lib.sh file not found or not readable."
  exit 1
fi

source $rundir/losd-lib.sh

# Set the filter if any.
filter=$1

# If the jq (JSON Query) Binary is installed.
jq_bin=`which jq > /dev/null 2>&1`
isjq=$?

# Filter
# echo $filter
if [ "$isjq" == "0" ]; then
  losd_json=$(losd)
  if [ $filter ]; then
    echo $losd_json | jq $filter | sed -r 's/"//g'
  else
    echo $losd_json | jq
  fi
else
  if [ $filter ]; then
    losd | grep $filter | cut -d ':' -f2 | sed -r 's/"//g' | sed -r 's/,$//'
  else
    losd
  fi
fi
