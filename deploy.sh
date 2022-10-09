#!/usr/bin/env bash

set -eu

function help_text {
  printf """
Deploy Express Hello world to instance(s).

Usage:
  --private-key    Private Key to use to authenticate
  --username       Username for instances to deploy to
  --hosts          Comma delimited list of hosts to deploy to.
  
Example:
  ./deploy.sh \\
    --private-key path_to_key.pem \\
    --username ubuntu \\
    --hosts 1.2.3.4,5.6.7.8
"""
}

while (("$#")); do
  case "$1" in
  --private-key)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      PRIVATE_KEY_LOCATION=$2
      shift 2
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --username)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      VM_USERNAME=$2
      shift 2
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --hosts)
    if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
      VM_HOSTS=$2
      shift 2
    else
      echo "ERROR: Argument for $1 is missing" >&2
      exit 1
    fi
    ;;
  --help)
    help_text
    exit 0
    ;;
  -* | --*=) # unsupported flags
    echo "ERROR: Unsupported flag $1" >&2
    exit 1
    ;;
  *) # preserve positional arguments
    PARAMS="$PARAMS $1"
    shift
    ;;
  esac
done

VM_HOSTS=$(echo $VM_HOSTS | tr -d " " | tr "," " ")

for INSTANCE_HOST in $VM_HOSTS; do
  echo "-- instance = $INSTANCE_HOST --"
  rsync -a -e "ssh -i $PRIVATE_KEY_LOCATION" --exclude='node_modules' app $VM_USERNAME@$INSTANCE_HOST:~
  ssh -i $PRIVATE_KEY_LOCATION $VM_USERNAME@$INSTANCE_HOST "bash -s" /home/$VM_USERNAME <remote.sh
done
