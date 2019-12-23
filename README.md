# AWS ECR anonymous proxy

Based on official nginx alpine.

[Docker image repository](https://hub.docker.com/r/catalinpan/aws-ecr-proxy/)

The container will renew the aws token every 6 hours.

Variables:
```
AWS_KEY
AWS_SECRET
REGION
RENEW_TOKEN - default 6h
REGISTRY_ID - optional, used for cross account access
```

### Health check 

To check the health of the container/registry use ```FQDN/ping``` which will give you the heath of the registry with the correct status code. 

### AWS instance with IAM role

For AWS instances if the region is not declared it will be auto discovered from IAM as long as the instance supports that. [pull request](https://github.com/catalinpan/aws-ecr-proxy/pull/1/commits/899ef1a80a7fa141f66e500a76f6ed86f8d19f4e), [commit](https://github.com/catalinpan/aws-ecr-proxy/commit/d8a709bf043cfd14b88defae738833e93c946f4b).

The AWS key and secret can be also configured using a IAM role (without mounting them secrets or specifying them as variables). A sample IAM role config can be found in the examples folder. More details on the [AWS official documentation](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html).

The configs will be checked in the following order:

- secrets - file mounted
- variables declared at run time
- IAM role

If none are found the container will not start. Check the logs with ```docker logs CONTAINER_ID```

## Docker run:
##### Without ssl
This will require either to add insecure registry URL or a load balancer with valid ssl certificates.
Check https://docs.docker.com/registry/insecure/ for more details.
```
docker run -e AWS_SECRET='YOUR_AWS_SECRET' \
-e AWS_KEY='YOUR_AWS_KEY' \
-e REGION='YOUR_AWS_REGION' \
-d catalinpan/aws-ecr-proxy
```
##### With your own certificate
```
docker run -e AWS_SECRET='YOUR_AWS_SECRET' \
-e AWS_KEY='YOUR_AWS_KEY' \
-e REGION='YOUR_AWS_REGION' \
-v `pwd`/YOUR_CERTIFICATE.key:/etc/nginx/ssl/default.key:ro \
-v `pwd`/YOUR_CERTIFICATE.crt:/etc/nginx/ssl/default.crt:ro \
-d catalinpan/aws-ecr-proxy
```
##### With a valid AWS CLI configuration file
The configuration should look like below example.  
```
cat ~/.aws/config
```
```
[default]
# region example eu-west-1
region = REGION     
aws_access_key_id = YOUR_AWS_KEY
aws_secret_access_key = YOUR_AWS_SECRET
```
```
docker run -v ~/.aws:/root/.aws:ro
-v `pwd`/YOUR_CERTIFICATE.key:/etc/nginx/ssl/default.key:ro \
-v `pwd`/YOUR_CERTIFICATE.crt:/etc/nginx/ssl/default.crt:ro \
-d catalinpan/aws-ecr-proxy
```
##### IAM role configured
with region and credentials from IAM role
```
docker run -d catalinpan/aws-ecr-proxy
```
with region as environment variable and credentials from IAM role
```
docker run -e REGION='YOUR_AWS_REGION' -d catalinpan/aws-ecr-proxy
```

## SSL
The certificates included are just to get nginx started. Generate your own certificate, get valid ssl certificates or use the container behind a load balancer with valid SSL certificates.

#### Self signed certificates
```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout default.key -out default.crt
```

## Kubernetes example

Kubernetes examples contain also a health check.
The configs can be changed to get aws_config and ssl certificates as secrets.

#### Deployment and service
The configuration provided will require valid ssl certificates or to be behind a load balancer with valid ssl.

#### DaemonSet
The daemonSet will be available on all the nodes. Deployments can use ```127.0.0.1:5000/container_name:tag``` instead of ```FQDN/container_name:tag```
