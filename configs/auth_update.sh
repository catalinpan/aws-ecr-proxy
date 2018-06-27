#!/bin/sh

nx_conf=/etc/nginx/nginx.conf

# update the auth token
auth=$(grep  X-Forwarded-User ${nx_conf} | awk '{print $4}'| uniq|tr -d "\n\r")
if [ "$REGISTRY_ID" = "" ]
then 
    token=$(aws ecr get-login --no-include-email | awk '{print $6}')
else
    aws_cli_exec=$(aws ecr get-login --no-include-email --registry-ids $REGISTRY_ID)
fi
auth_n=$(echo AWS:${token}  | base64 |tr -d "[:space:]")

sed -i "s|${auth%??}|${auth_n}|g" ${nx_conf}
