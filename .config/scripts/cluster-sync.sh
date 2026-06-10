#!/bin/bash

/usr/bin/rclone sync "$HOME/cluster" cluster_crypt: \
  --transfers=4 \
  --checkers=8 \
  --delete-during \
  --log-file="$HOME/.local/share/rclone/cluster.log" \
  --log-level=INFO
