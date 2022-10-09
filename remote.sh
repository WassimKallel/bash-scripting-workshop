#!/usr/bin/env bash

set -e

LOCATION=$1

if ! type node; then
  echo "-- Installing Node --"
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get update
  sudo apt-get install -y nodejs
else
  echo "-- Node already installed --"
fi

if ! type forever; then
  echo "-- Installing Forever --"
  sudo npm i -g forever
else
  echo "-- Forever already installed --"
fi

# Make Logs directory if it does not exists
mkdir -p $LOCATION/logs

cd $LOCATION/app
npm install

# Substitue the placeholder with correct path
APP_LOCATION=$LOCATION envsubst < forever.json

(forever list | grep app) || forever start forever.json
