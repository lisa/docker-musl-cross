#!/bin/bash
# Tags and publishes to Docker Hub

set +x

REPO="thedoh/musl-cross"

if [[ -z $TRAVIS_BRANCH ]]; then
  echo "Undefined TRAVIS_BRANCH. Can't safely publish image because we don't know what musl version was used. Aborting."
  exit 1
fi

echo "Changing directory to $(dirname $0)/.."
cd "$(dirname $0)/.."

if [[ -z $DOCKER_PASS ]]; then
  echo "Don't know the docker password. Aborting."
  exit 1
fi

docker login -e=$DOCKER_MAIL -u=thedoh -p=$DOCKER_PASS
if [[ $? -ne 0 ]]; then
  echo "Could not log in to Docker Hub (Exit: $?). Aborting."
  exit 1
fi

# If this is from a merge to master then it should be tagged 'latest'
if [[ $TRAVIS_BRANCH == "master" ]]; then
  docker tag $REPO:$TRAVIS_COMMIT $REPO:latest
else
  docker tag $REPO:$TRAVIS_COMMIT $REPO:$TRAVIS_BRANCH  
fi

docker push $REPO
