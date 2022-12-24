#!/bin/sh
# build image menggunakan tag item-app:v1
docker build . -t item-app:v1
# menampilkan daftar image
docker image ls
# membuat tag baru dari item-app:v1 ghcr.io/berviantoleo/a433-microservices:v1
docker tag item-app:v1 ghcr.io/wilsonoey60/a433-microservices:v1
