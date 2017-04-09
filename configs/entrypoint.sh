#!/bin/sh

nx_conf=/etc/nginx/nginx.conf

AWS_IAM='http://169.254.169.254/latest/dynamic/instance-identity/document'
AWS_FOLDER='/root/.aws'

region_config() {
  echo  "region = $@" >> /root/.aws/config
}

if [[ "$AWS_KEY" != "" && "$AWS_SECRET" != "" ]]
then
  mkdir -p ${AWS_FOLDER}
  echo "***REMOVED***
aws_access_key_id = $AWS_KEY
aws_secret_access_key = $AWS_SECRET" > ${AWS_FOLDER}/config

	if [[ "$REGION" != "" ]]
	then
	  region_config $REGION
# check if the region can be pulled from AWS IAM
	elif wget -q -O- ${AWS_IAM} | grep -q 'region'
	then
		REGION=$(wget -q -O- ${AWS_IAM} | grep 'region'|cut -d'"' -f4)
		region_config $REGION
# error exit
	else
		echo "No region detected"
		exit 1
	fi
# fix the permissions
chmod 600 -R ${AWS_FOLDER}
fi


# update the auth token
aws_cli_exec=$(aws ecr get-login)
auth=$(grep  X-Forwarded-User ${nx_conf} | awk '{print $4}'| uniq|tr -d "\n\r")
token=$(echo "${aws_cli_exec}" | awk '{print $6}')
auth_n=$(echo AWS:${token}  | base64 |tr -d "[:space:]")
reg_url=$(echo "${aws_cli_exec}" | awk '{print $9}')

sed -i "s|${auth%??}|${auth_n}|g" ${nx_conf}
sed -i "s|REGISTRY_URL|$reg_url|g" ${nx_conf}

/renew_token.sh &

exec "$@"
