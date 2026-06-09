#!/bin/bash

/usr/bin/rclone sync /home/voidpkr/cluster cluster_crypt: \
  --transfers=4 \
  --checkers=8 \
  --delete-during \
  --log-file=/home/voidpkr/.local/share/rclone/cluster.log \
  --log-level=INFO
