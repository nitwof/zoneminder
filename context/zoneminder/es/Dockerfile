ARG zm_version
FROM zoneminder:${zm_version}

ARG es_version
ARG DEBIAN_FRONTEND="noninteractive"

ENV \
    ES_VERSION="${es_version}"

RUN \
    apt-get update && \
    # Install event server dependenceis
    apt-get install -y --no-install-recommends \
      build-essential \
      git-core \
      curl \
      libcrypt-eksblowfish-perl \
      libcrypt-mysql-perl \
      libjson-perl \
      libmodule-build-perl \
      libyaml-perl \
      python3-dev \
      python3-distutils \
    && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python3 && \
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
    git clone --depth 1 -b "v${ES_VERSION}" \
      "https://github.com/pliablepixels/zmeventnotification.git" \
      /tmp/zmeventnotification \
    && \
    cd /tmp/zmeventnotification && \
    ./install.sh \
      --no-interactive \
      --install-config \
      --install-es \
      --install-hook \
      --no-download-models \
    && \
    # Move base entrypoint
    mv /entrypoint.sh /zm-entrypoint.sh && \
    # Cleanup
    apt-get remove -y \
      build-essential \
      git-core \
      curl \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache || true && \
    truncate -s 0 /var/log/*log

COPY ./entrypoint.sh /entrypoint.sh

VOLUME [ "/var/lib/zmeventnotification/push" ]
EXPOSE 9000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/zoneminder" ]