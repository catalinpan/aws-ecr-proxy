#!/bin/sh

nx_conf=/etc/nginx/nginx.conf

AWS_IAM='http://169.254.169.254/latest/dynamic/instance-identity/document'
AWS_FOLDER='/root/.aws'

header_config() {
    mkdir -p ${AWS_FOLDER}
    echo "[default]" > /root/.aws/config
}
region_config() {
    echo  "region = $@" >> /root/.aws/config
}

test_iam() {
    wget -q -O- ${AWS_IAM} | grep -q 'region'
}

test_config() {
    grep -qrni $@ ${AWS_FOLDER}
}

fix_perm() {
    chmod 600 -R ${AWS_FOLDER}
}

# test if region is mounted as secret
if test_config region
then
    echo "region found in ~/.aws mounted as secret"
# configure regions if variable specified at run time
elif [[ "$REGION" != "" ]]
then
    header_config
    region_config $REGION
    fix_perm
# check if the region can be pulled from AWS IAM
elif test_iam
then
    echo "region detected from iam"
    REGION=$(wget -q -O- ${AWS_IAM} | grep 'region' |cut -d'"' -f4)
    header_config
    region_config $REGION
    fix_perm
else
  echo "No region detected"
  exit 1
fi


if aws ecr get-authorization-token | grep expiresAt
then
    echo "IAM role configured to allow ECR access."
else
    echo "Error: ECR access not configured."
    exit 1
fi

# update the auth token
if [ "$REGISTRY_ID" = "" ]
then 
    aws_cli_exec=$(aws ecr get-login --no-include-email)
else
    aws_cli_exec=$(aws ecr get-login --no-include-email --registry-ids $REGISTRY_ID)
fi
auth=$(grep  X-Forwarded-User ${nx_conf} | awk '{print $4}'| uniq|tr -d "\n\r")
token=$(echo "${aws_cli_exec}" | awk '{print $6}')
auth_n=$(echo AWS:${token}  | base64 |tr -d "[:space:]")
reg_url=$(echo "${aws_cli_exec}" | awk '{print $7}')

sed -i "s|${auth%??}|${auth_n}|g" ${nx_conf}
sed -i "s|REGISTRY_URL|$reg_url|g" ${nx_conf}

/renew_token.sh &

exec "$@"
