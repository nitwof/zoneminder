#!/bin/bash
set -e

# Init user by MLAPI_USER and MLAPI_PASSWORD env variables
python3 ./init_user.py

exec "$@"