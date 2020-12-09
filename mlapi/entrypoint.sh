#!/bin/bash
set -e

# Create MLAPI config (secrets.ini) based on env variables
rm -f ${MLAPI_DIR}/secrets.ini
for kv in $(env | grep "MLAPI_"); do
  echo "${kv/MLAPI_}" >> ${MLAPI_DIR}/secrets.ini
done

# Init user by MLAPI_USER and MLAPI_PASSWORD env variables
python3 ${MLAPI_DIR}/init_user.py

exec "$@"