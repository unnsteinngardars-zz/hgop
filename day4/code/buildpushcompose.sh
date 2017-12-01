#!/bin/bash
docker build -t ungar/week1:$1 .
docker push ungar/week1:$1
docker-compose up
