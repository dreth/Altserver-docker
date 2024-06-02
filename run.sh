#!/bin/bash

# Build the Docker image
docker build . -t altserver-docker && \

# Stop and remove any existing container
docker stop altserver || true && \
docker rm altserver || true && \

# Run the container
sudo docker run -d \
  -v "./lib:/root/.config/Provision/lib" \
  -v "./logs:/altserver/logs" \
  -v "./bin:/altserver/bin" \
  -v "/dev/bus/usb:/dev/bus/usb" \
  -v "/var/lib/lockdown:/var/lib/lockdown" \
  -v "/var/run:/var/run" \
  -v "/sys/fs/cgroup:/sys/fs/cgroup:ro" \
  --name altserver \
  --network host \
  --privileged \
  altserver-docker && \

# Follow the logs
docker logs -f altserver
