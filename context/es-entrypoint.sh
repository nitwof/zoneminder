#!/bin/bash

# Init tokens.txt if it does not exist
if [ ! -f /var/lib/zmeventnotification/push/tokens.txt ]
then
  echo "{}" > /var/lib/zmeventnotification/push/tokens.txt
fi

# Set permissions on important directories
chown -R www-data:www-data \
  /var/lib/zmeventnotification

exec /entrypoint.sh "$@"