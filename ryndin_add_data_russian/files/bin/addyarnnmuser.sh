#!/usr/bin/env bash

# USE THIS SCRIPT IN YARN-NM TO CREATE A NEW USER

if [ "$1" == "" ];then
    echo "Username is not specified..."
    exit 1
fi

USERNAME=$1

useradd -r -g osa -G share -s /bin/bash ${USERNAME}
