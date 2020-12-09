ARG ffmpeg_version
FROM jrottenberg/ffmpeg:${ffmpeg_version}

ARG version
ARG DEBIAN_FRONTEND="noninteractive"

ENV \
    ZM_VERSION="${version}" \
    PHP_VERSION="7.2" \
    TZ="Etc/UTC"

RUN \
    apt-get update && \
    # Install common dependencies
    apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg \
      net-tools \
      rsyslog \
      sudo \
    && \
    # Add zoneminder ppa repository https://launchpad.net/~iconnor/+archive/ubuntu/zoneminder-1.34
    export $(cat /etc/os-release | grep UBUNTU_CODENAME) && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "776FFB04" && \
    echo "deb http://ppa.launchpad.net/iconnor/zoneminder-${ZM_VERSION}/ubuntu ${UBUNTU_CODENAME} main" > \
    /etc/apt/sources.list.d/zoneminder-${ZM_VERSION}.list && \
    echo "deb-src http://ppa.launchpad.net/iconnor/zoneminder-${ZM_VERSION}/ubuntu ${UBUNTU_CODENAME} main" >> \
    /etc/apt/sources.list.d/zoneminder-${ZM_VERSION}.list && \
    apt-get update && \
    # Install zoneminder https://github.com/ZoneMinder/zoneminder
    apt-get install -y --no-install-recommends zoneminder && \
    rm -f /usr/bin/ffmpeg && \
    mkdir -p /var/log/stdout && \
    ln -s /dev/stdout /var/log/stdout/zm.log && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true && \
    truncate -s 0 /var/log/*log

COPY ./rsyslog.conf /etc/rsyslog.conf
COPY ./zm.conf /etc/zm/conf.d/10-zm.conf
COPY ./zoneminder /usr/sbin/zoneminder
COPY ./entrypoint.sh /entrypoint.sh

VOLUME [ "/var/cache/zoneminder", "/var/log/zm", "/var/run/zm", "/tmp/zm" ]
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/zoneminder" ]