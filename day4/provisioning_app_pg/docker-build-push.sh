#!/bin/bash
GIT_COMMIT=$(git rev-parse HEAD)
docker build -t pagecounter
docker tag pagecounter ungar/week1:$GIT_COMMIT
docker push ungar/week1:$GIT_COMMIT
