#!/bin/bash
COMMIT=$(git rev-parse --verify HEAD)
docker image build -f "Dockerfile" . \
  -t "maximkuzmin/checklister:latest" \
  -t "maximkuzmin/checklister:${COMMIT}"

docker push maximkuzmin/checklister:latest
