ARG mlbase_version
FROM mlbase:${mlbase_version}

ARG version
ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALL_CORAL_EDGETPU="no"
ARG INSTALL_TINYYOLOV3="yes"
ARG INSTALL_TINYYOLOV4="yes"
ARG INSTALL_YOLOV3="yes"
ARG INSTALL_YOLOV4="yes"

ENV \
    MLAPI_VERSION="${version}" \
    MLAPI_DIR="/mlapi"

RUN \
    apt-get update && \
    # Install dependenceis
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      wget \
    && \
    # Install mlapi https://github.com/pliablepixels/mlapi
    git clone --depth 1 -b "${MLAPI_VERSION}" \
      "https://github.com/pliablepixels/mlapi" ${MLAPI_DIR} && \
    cd ${MLAPI_DIR} && \
    python3 -m pip install --no-cache-dir -r ./requirements.txt && \
    ./get_models.sh && \
    # Cleanup
    apt-get remove -y \
      build-essential \
      git \
      wget \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache && \
    truncate -s 0 /var/log/*log

COPY ./init_user.py ${MLAPI_DIR}/
COPY ./entrypoint.sh /entrypoint.sh

WORKDIR ${MLAPI_DIR}

VOLUME [ "${MLAPI_DIR}/images", "${MLAPI_DIR}/known_faces", "${MLAPI_DIR}/unknown_faces", "${MLAPI_DIR}/db" ]
EXPOSE 5000
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "python3", "./mlapi.py", "-c", "./mlapiconfig.ini" ]