#!/bin/sh

nginx -g "daemon off;" &

while sleep 6h
do
  /auth_update.sh
  nginx -s reload
done
