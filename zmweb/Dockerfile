ARG zm_version
FROM nitwof/zoneminder:${zm_version}

RUN \
    apt-get update && \
    # Install apache2
    apt-get install -y --no-install-recommends \
      apache2 \
      libapache2-mod-php \
    && \
    # Configure apache2
    a2enmod cgi && \
    a2enmod expires && \
    a2enmod headers && \
    a2enmod php${PHP_VERSION} && \
    a2enmod rewrite && \
    a2enconf zoneminder && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    rm -rf /var/log/apache2/* && \
    ln -s /dev/stdout /var/log/apache2/access.log && \
    ln -s /dev/stderr /var/log/apache2/error.log && \
    # Move base entrypoint
    mv /entrypoint.sh /zm-entrypoint.sh && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true && \
    truncate -s 0 /var/log/*log

COPY ./entrypoint.sh /entrypoint.sh

STOPSIGNAL SIGWINCH
EXPOSE 80
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "apache2ctl", "-DFOREGROUND" ]