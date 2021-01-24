#!/bin/bash
export GOOGLE_PROJECT=docker-29
docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-disk-size 65 \
--google-zone europe-west1-d \
gitlab-ci