#!/bin/sh

while sleep ${RENEW_TOKEN:-6h}
do
  /auth_update.sh
  nginx -s reload
done
