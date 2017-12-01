#!/bin/bash
docker build -t ungar/week1:test .
docker push ungar/week1:test
docker-compose up