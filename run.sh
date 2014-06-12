#!/bin/sh
docker run -d -t -p 127.0.0.1:8000:80 -p 127.0.0.1:2222:22 abyz-drupal
