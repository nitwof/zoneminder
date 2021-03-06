FROM ubuntu:18.04

ARG version
ARG zm_version
ARG python_version
ARG DEBIAN_FRONTEND="noninteractive"

ENV \
    PYTHON_VERSION="${python_version}"

RUN \
    apt-get update && \
    # Install base dependencies
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      python${PYTHON_VERSION} \
      python${PYTHON_VERSION}-distutils \
    && \
    rm -f /usr/bin/python3 && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python3 && \
    # Install opencv
    python3 -m pip install --no-cache-dir opencv-contrib-python && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache || true && \
    truncate -s 0 /var/log/*log

ENV \
    ZM_VERSION="${zm_version}"

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
      libcrypt-eksblowfish-perl \
      libcrypt-mysql-perl \
      libjson-perl \
      libmodule-build-perl \
      libyaml-perl \
      zoneminder \
    && \
    rm -rf /usr/share/zoneminder && \
    # Install perl dependencies for zmeventnotification
    perl -MCPAN -e "force install Config::IniFiles" && \
    perl -MCPAN -e "force install Crypt::Eksblowfish::Bcrypt" && \
    perl -MCPAN -e "force install Crypt::MySQL" && \
    perl -MCPAN -e "force install LWP::Protocol::https" && \
    perl -MCPAN -e "force install Net::MQTT::Simple::Auth" && \
    perl -MCPAN -e "force install Net::MQTT::Simple" && \
    perl -MCPAN -e "force install Net::WebSocket::Server" && \
    perl -MCPAN -e "force install Time::Piece" && \
    # Cleanup
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache && \
    truncate -s 0 /var/log/*log

ENV \
    ZMEN_VERSION="${version}" \
    ZMEN_DIR="/var/lib/zmeventnotification"

RUN \
    apt-get update && \
    # Install zmeventnotification dependencies
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      python${PYTHON_VERSION}-dev \
    && \
    # Install zmeventnotification https://github.com/pliablepixels/zmeventnotification
    git clone --depth 1 -b "v${ZMEN_VERSION}" \
      "https://github.com/pliablepixels/zmeventnotification.git" \
      /tmp/zmeventnotification && \
    cd /tmp/zmeventnotification && \
    ./install.sh \
      --install-config \
      --install-es \
      --install-hook \
      --no-download-models \
      --no-interactive \
      --no-pysudo \
    && \
    # Cleanup
    apt-get remove -y \
      build-essential \
      git \
      python${PYTHON_VERSION}-dev \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache && \
    truncate -s 0 /var/log/*log

COPY ./entrypoint.sh /entrypoint.sh

VOLUME [ "${ZMEN_DIR}/push", "${ZMEN_DIR}/images" ]
EXPOSE 9000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/zmeventnotification.pl" ]