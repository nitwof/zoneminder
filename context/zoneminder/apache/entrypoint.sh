#!/bin/bash

# Setup apache timezone
sed -i "s|^;date.timezone =.*|date.timezone = ${TZ}|" /etc/php/${PHP_VERSION}/apache2/php.ini

exec /zm-entrypoint.sh "$@"