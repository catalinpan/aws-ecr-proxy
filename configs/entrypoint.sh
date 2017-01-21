#!/bin/sh

nx_conf=/etc/nginx/nginx.conf

if [[ "$REGION" != "" && "$AWS_KEY" != "" && "$AWS_SECRET" != "" ]]; then
# create aws directory
mkdir -p /root/.aws

echo "[default]
region = $REGION
aws_access_key_id = $AWS_KEY
aws_secret_access_key = $AWS_SECRET" > /root/.aws/config

chmod 600 -R /root/.aws
fi

# update the auth token
auth=$(grep  X-Forwarded-User ${nx_conf} | awk '{print $4}'| uniq|tr -d "\n\r")
token=$(aws ecr get-login | awk '{print $6}')
auth_n=$(echo AWS:${token}  | base64 |tr -d "[:space:]")
reg_url=$(aws ecr get-login | awk '{print $9}')

sed -i "s|${auth%??}|${auth_n}|g" ${nx_conf}
sed -i "s|REGISTRY_URL|$reg_url|g" ${nx_conf}

exec "$@"
