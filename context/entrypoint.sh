#!/bin/bash
set -e

# Setup timezone
echo "Setting the timezone: ${TZ}"
if [[ $(cat /etc/timezone) != "${TZ}" ]]; then
	echo "$TZ" > /etc/timezone
	ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime
	DEBIAN_FRONTEND=noninteractive dpkg-reconfigure tzdata
fi
sed -i "s|^;date.timezone =.*|date.timezone = ${TZ}|" /etc/php/${PHP_VERSION}/apache2/php.ini

# Create zm config based on env variables
for kv in $(env | grep "ZM_"); do
  echo $kv >> /etc/zm/conf.d/20-zm.conf
done

# Setup volume directories
mkdir -p /var/cache/zoneminder/cache \
         /var/cache/zoneminder/events \
         /var/cache/zoneminder/images \
         /var/cache/zoneminder/temp

# Set permissions on important directories
chown -R www-data:www-data \
  /var/cache/zoneminder \
  /var/log/zm \
  /usr/share/zoneminder

exec "$@"
