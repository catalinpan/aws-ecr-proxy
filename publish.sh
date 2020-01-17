#!/bin/sh

set -e

usage () {
    printf "NAME\n"
    printf "    publish.sh -- push Docker image to registry.\n"
    printf "SYNOPSIS\n"
    printf "    publish.sh [options]\n"
    printf "DESCRIPTION\n"
    printf "    publish.sh is a tool for pushing the Docker image to registry.\n"
    printf "OPTIONS\n"
    printf "    -h, --help\n"
    printf "        Usage help. This lists all current command line options with a short description.\n"
    printf "    --latest\n"
    printf "        Also push/update the latest tag.\n"
    printf "    --name=<value>\n"
    printf "        The name of the Docker image to publish, default to 'catalinpan/aws-ecr-proxy'.\n"
    printf "    --version\n"
    printf "        The version of the Docker image to publish, default to the content of 'version.txt'.\n"
}

NAME=catalinpan/aws-ecr-proxy
VERSION=$(cat version.txt)

while [ $# -gt 0 ]
do
    case $1 in
    -h | --help)
        usage
        exit
        ;;
    --latest)
        PUSH_LATEST=1
        ;;
    --name=*)
        NAME=${1#*=}
        ;;
    --version=*)
        VERSION=${1#*=}
        ;;
    *)
        usage
        exit
        ;;
    esac
    shift
done

MAJOR=$(echo "${VERSION}" | awk -F '.' '{print $1}')
MINOR=$(echo "${VERSION}" | awk -F '.' '{print $2}')
PATCH=$(echo "${VERSION}" | awk -F '.' '{print $3}')

docker login

if [ -n "${PUSH_LATEST}" ]; then
    docker tag "${NAME}:${VERSION}" "${NAME}:latest"
    docker push "${NAME}:latest"
fi

docker tag "${NAME}:${VERSION}" "${NAME}:${MAJOR}.${MINOR}.${PATCH}"
docker tag "${NAME}:${VERSION}" "${NAME}:${MAJOR}.${MINOR}"
docker tag "${NAME}:${VERSION}" "${NAME}:${MAJOR}"

docker push "${NAME}:${MAJOR}.${MINOR}.${PATCH}"
docker push "${NAME}:${MAJOR}.${MINOR}"
docker push "${NAME}:${MAJOR}"
