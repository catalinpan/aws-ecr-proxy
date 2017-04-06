#!/bin/sh

nx_conf=/etc/nginx/nginx.conf

MYREGION=$(wget -q -O- http://169.254.169.254/latest/dynamic/instance-identity/document|grep 'region'|cut -d'"' -f4)

REGION=${REGION:-$MYREGION}

# create aws directory
mkdir -p /root/.aws

cat << EOF > /root/.aws/config
***REMOVED***
region = $REGION
EOF

if [[ "$AWS_KEY" != "" && "$AWS_SECRET" != "" ]]; then
	cat << EOF >> /root/.aws/config
	aws_access_key_id = $AWS_KEY
	aws_secret_access_key = $AWS_SECRET"
EOF
fi

chmod 600 -R /root/.aws

# update the auth token
auth=$(grep  X-Forwarded-User ${nx_conf} | awk '{print $4}'| uniq|tr -d "\n\r")
token=$(aws ecr get-login | awk '{print $6}')
auth_n=$(echo AWS:${token}  | base64 |tr -d "[:space:]")
reg_url=$(aws ecr get-login | awk '{print $9}')

sed -i "s|${auth%??}|${auth_n}|g" ${nx_conf}
sed -i "s|REGISTRY_URL|$reg_url|g" ${nx_conf}

/renew_token.sh &

exec "$@"
