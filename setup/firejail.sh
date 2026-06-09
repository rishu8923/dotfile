#!/usr/bin/env bash
set -e

echo "Enabling Firejail sandboxing..."

sudo firecfg

echo "Firejail setup complete."
