#!/bin/sh

usage () {
    printf "NAME\n"
    printf "    build.sh -- build a new Docker image.\n"
    printf "SYNOPSIS\n"
    printf "    build.sh [options]\n"
    printf "DESCRIPTION\n"
    printf "    build.sh is a tool to build a new Docker image.\n"
    printf "OPTIONS\n"
    printf "    -h, --help\n"
    printf "        Usage help. This lists all current command line options with a short description.\n"
    printf "    --name=<value>\n"
    printf "        The name of the Docker image to build, default to 'catalinpan/aws-ecr-proxy'.\n"
    printf "    --version\n"
    printf "        The version of the Docker image to build, default to the content of 'version.txt'.\n"
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

docker build --no-cache --pull -t "${NAME}:${VERSION}" .
