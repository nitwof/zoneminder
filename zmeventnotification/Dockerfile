ARG mlbase_version
FROM mlbase:${mlbase_version}

ARG version
ARG zm_version
ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALL_CORAL_EDGETPU="no"
ARG INSTALL_TINYYOLOV3="yes"
ARG INSTALL_TINYYOLOV4="yes"
ARG INSTALL_YOLOV3="yes"
ARG INSTALL_YOLOV4="yes"

ENV \
    ZMEN_VERSION="${version}" \
    ZM_VERSION="${zm_version}" \
    ZMEN_DIR="/var/lib/zmeventnotification"

RUN \
    # Add zoneminder ppa repository https://launchpad.net/~iconnor/+archive/ubuntu/zoneminder-1.34
    export $(cat /etc/os-release | grep UBUNTU_CODENAME) && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "776FFB04" && \
    echo "deb http://ppa.launchpad.net/iconnor/zoneminder-${ZM_VERSION}/ubuntu ${UBUNTU_CODENAME} main" > \
    /etc/apt/sources.list.d/zoneminder-${ZM_VERSION}.list && \
    echo "deb-src http://ppa.launchpad.net/iconnor/zoneminder-${ZM_VERSION}/ubuntu ${UBUNTU_CODENAME} main" >> \
    /etc/apt/sources.list.d/zoneminder-${ZM_VERSION}.list && \
    apt-get update && \
    # Install zmeventnotification dependencies
    apt-get install -y --no-install-recommends \
      build-essential \
      git-core \
      libcrypt-eksblowfish-perl \
      libcrypt-mysql-perl \
      libjson-perl \
      libmodule-build-perl \
      libyaml-perl \
      zoneminder \
      wget \
    && \
    # Install perl dependencies for zmeventnotification
    perl -MCPAN -e "install Config::IniFiles" && \
    perl -MCPAN -e "install Crypt::Eksblowfish::Bcrypt" && \
    perl -MCPAN -e "install Crypt::MySQL" && \
    perl -MCPAN -e "install LWP::Protocol::https" && \
    perl -MCPAN -e "install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "install Net::MQTT::Simple" && \
    perl -MCPAN -e "install Net::WebSocket::Server" && \
    perl -MCPAN -e "install Time::Piece" && \
    # Install zmeventnotification https://github.com/pliablepixels/zmeventnotification
    git clone --depth 1 -b "v${ZMEN_VERSION}" \
      "https://github.com/pliablepixels/zmeventnotification.git" \
      /tmp/zmeventnotification && \
    cd /tmp/zmeventnotification && \
    ./install.sh \
      --no-interactive \
      --no-pysudo \
      --install-config \
      --install-es \
      --install-hook \
      --download-models \
    && \
    # Cleanup
    apt-get remove -y \
      build-essential \
      git-core \
      wget \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache || true && \
    truncate -s 0 /var/log/*log

COPY ./entrypoint.sh /entrypoint.sh

VOLUME [ "${ZMEN_DIR}/push", "${ZMEN_DIR}/images", "${ZMEN_DIR}/known_faces", "${ZMEN_DIR}/unknown_faces" ]
EXPOSE 9000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/zmeventnotification.pl" ]