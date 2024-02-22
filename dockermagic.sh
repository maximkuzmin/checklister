#!/bin/bash
COMMIT=$(git rev-parse --verify HEAD)
docker image build -f “Dockerfile” . \
  --build-arg “app_name=Checklister” \
  -t “MyApp:latest” \
  -t “MyApp:${COMMIT}
