ARG python_version="3.9"
ARG opencv_verison="4.1.2"
ARG face_recognition_version="1.3.0"
FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04 AS build-base

ENV	\
    DEBIAN_FRONTEND="noninteractive" \
    PYTHON_VERSION="${python_version}"

RUN \
    export $(cat /etc/os-release | grep UBUNTU_CODENAME) && \
    # Add python ppa https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "6A755776" && \
    echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${UBUNTU_CODENAME} main" > \
      /etc/apt/sources.list.d/python.list && \
    echo "deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${UBUNTU_CODENAME} main" >> \
      /etc/apt/sources.list.d/python.list && \
    # Add ffmpeg ppa https://launchpad.net/~jonathonf/+archive/ubuntu/ffmpeg-4
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "F06FC659" && \
    echo "deb http://ppa.launchpad.net/jonathonf/ffmpeg-4/ubuntu ${UBUNTU_CODENAME} main" > \
      /etc/apt/sources.list.d/ffmpeg.list && \
    echo "deb-src http://ppa.launchpad.net/jonathonf/ffmpeg-4/ubuntu ${UBUNTU_CODENAME} main" >> \
      /etc/apt/sources.list.d/ffmpeg.list && \
    apt-get update && \
    # Install base build dependencies
    apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      ccache \
      curl \
      git-core \
      pkg-config \
      python${PYTHON_VERSION} \
      python${PYTHON_VERSION}-dev \
      python${PYTHON_VERSION}-distutils \
    && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python3 && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

FROM build-base AS opencv-build

ENV	\
    OPENCV_VERSION="${opencv_version}" \
    OPENCV_PATH="/opencv"

RUN \
    apt-get update && \
    # Install opencv build dependencies
    deps="\
      doxygen \
      ffmpeg \
      gfortran \
      libatlas-dev \
      libavcodec-dev \
      libavformat-dev \
      libavresample-dev \
      libdc1394-22-dev \
      libeigen3-dev \
      libfaac-dev \
      libgflags-dev \
      libgoogle-glog-dev \
      libgphoto2-dev \
      libgstreamer-plugins-base1.0-dev \
      libgstreamer1.0-dev \
      libhdf5-dev \
      libjpeg-dev \
      liblapack-dev \
      liblapacke-dev \
      libleptonica-dev \
      libmp3lame-dev \
      libopenblas-dev \
      libopencore-amrnb-dev \
      libopencore-amrwb-dev \
      libopenexr-dev \
      libopenjp2-7-dev \
      libpng-dev \
      libprotobuf-dev \
      libswscale-dev \
      libtbb-dev \
      libtesseract-dev \
      libtheora-dev \
      libtiff-dev \
      libv4l-dev \
      libvorbis-dev \
      libvtk6-dev \
      libwebp-dev \
      libx264-dev \
      libxine2-dev \
      libxvidcore-dev \
      protobuf-compiler \
      unzip \
      yasm \
      zlib1g-dev \
    " && \
    apt-get install -y --no-install-recommends ${deps} && \
    python3 -m pip install numpy && \
    # Workaround for openblas lapacke
    # See: https://github.com/opencv/opencv/issues/9953
    ln -s /usr/include/lapacke.h /usr/include/openblas/ && \
    # Build opencv https://opencv.org
    git clone -b "${OPENCV_VERSION}" --depth 1 \
      "https://github.com/opencv/opencv.git" /tmp/opencv && \
    git clone -b "${OPENCV_VERSION}" --depth 1 \
      "https://github.com/opencv/opencv_contrib.git" /tmp/opencv/contrib && \
    mkdir -p /tmp/opencv/build && \
    cd /tmp/opencv/build && \
    cmake \
      -BUILD_SHARED_LIBS=ON \
      -DBUILD_EXAMPLES=OFF \
      -DBUILD_FAT_JAVA_LIB=OFF \
      -DBUILD_JAVA=OFF \
      -DBUILD_OBJC=OFF \
      -DBUILD_opencv_python2=OFF \
      -DBUILD_opencv_python3=ON \
      -DCMAKE_BUILD_TYPE=RELEASE \
      -DCMAKE_INSTALL_PREFIX=${OPENCV_PATH} \
      -DENABLE_CCACHE=ON \
      -DOPENCV_ENABLE_NONFREE=ON \
      -DOPENCV_EXTRA_MODULES_PATH=/tmp/opencv/contrib/modules \
      -DWITH_CUDA=ON \
      -DWITH_CUBLAS=ON \
      -DWITH_CUFFT=ON \
      -DWITH_NVCUVID=ON \
      -DCUDA_FAST_MATH=1 \
      -DENABLE_FAST_MATH=ON \
      -DWITH_CUDNN=ON \
      -DWITH_FFMPEG=ON \
      -DWITH_OPENEXR=ON \
      -DWITH_OPENMP=ON \
      -DWITH_TBB=ON \
      /tmp/opencv \
    && \
    make -j$(nproc) && \
    make install && \
    # Cleanup
    apt-get remove -y ${deps} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

FROM build-base AS face_recognition-build

ENV \
    FACE_RECOGNITION_VERSION="${face_recognition_version}" \
    FACE_RECOGNITION_PATH="/face_recognition"

RUN \
    apt-get update -qq && \
    # Install face_recognition build dependencies
    deps="\
      libblas-dev \
      libgif-dev \
      libjpeg-dev \
      liblapack-dev \
      liblapacke-dev \
      libopenblas-dev \
      libpng-dev \
    " && \
    apt-get install -y --no-install-recommends ${deps} && \
    # Build face_recognition https://github.com/ageitgey/face_recognition
    mkdir -p /tmp/face_recognition && \
    python3 -m pip install --no-cache-dir --root /tmp/face_recognition -v \
      numpy \
      mkl_fft \
      face_recognition==${FACE_RECOGNITION_VERSION} \
    && \
    mv /tmp/face_recognition/usr/local ${FACE_RECOGNITION_PATH} && \
    # Cleanup
    apt-get remove -y ${deps} && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

FROM nvidia/cuda:9.1-cudnn7-runtime-ubuntu16.04

ARG DEBIAN_FRONTEND="noninteractive"

ENV \
    OPENCV_VERSION="${opencv_version}" \
    FACE_RECOGNITION_VERSION="${face_recognition_version}" \
    PYTHON_VERSION="${python_version}" \
    APP_DIR="/mlapi"

# Copy opencv files
COPY --from=opencv-build /opencv/ /usr/local/
# Copy face_recognition files
COPY --from=face_recognition-build /face_recognition/ /usr/local/

RUN \
    export $(cat /etc/os-release | grep UBUNTU_CODENAME) && \
    # Add python ppa https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "6A755776" && \
    echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${UBUNTU_CODENAME} main" > \
      /etc/apt/sources.list.d/python.list && \
    echo "deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu ${UBUNTU_CODENAME} main" >> \
      /etc/apt/sources.list.d/python.list && \
    # Add ffmpeg ppa https://launchpad.net/~jonathonf/+archive/ubuntu/ffmpeg-4
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "F06FC659" && \
    echo "deb http://ppa.launchpad.net/jonathonf/ffmpeg-4/ubuntu ${UBUNTU_CODENAME} main" > \
      /etc/apt/sources.list.d/ffmpeg.list && \
    echo "deb-src http://ppa.launchpad.net/jonathonf/ffmpeg-4/ubuntu ${UBUNTU_CODENAME} main" >> \
      /etc/apt/sources.list.d/ffmpeg.list && \
    apt-get update && \
    # Install python
    apt-get install -y --no-install-recommends \
      python${PYTHON_VERSION} \
      python${PYTHON_VERSION}-distutils \
    && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    curl "https://bootstrap.pypa.io/get-pip.py" | python3 && \
    # Install dependenceis
    apt-get install -y --no-install-recommends \
      # opencv dependencies
      libatlas3-base \
      libavcodec58 \
      libavformat58 \
      libavresample4 \
      libdc1394-22 \
      libfaac0 \
      libgflags2v5 \
      libgoogle-glog0v5 \
      libgphoto2-6 \
      libgstreamer-plugins-base1.0-0 \
      libgstreamer1.0-0 \
      libhdf5-10 \
      libjpeg8 \
      liblapack3 \
      liblapacke \
      libmp3lame0 \
      libopenblas-base \
      libopencore-amrnb0 \
      libopencore-amrwb0 \
      libopenexr22 \
      libopenjp2-7 \
      libpng12-0 \
      libprotobuf9v5 \
      libswscale5 \
      libtbb2 \
      libtesseract3 \
      libtheora0 \
      libtiff5 \
      libv4l-0 \
      libvorbis0a \
      libvtk6.2 \
      libwebp5 \
      libx264-155 \
      libxine2 \
      libxvidcore4 \
      zlib1g \
      # face_recognition dependencies
      libblas3 \
      libgif7 \
      libjpeg8 \
      liblapack3 \
      liblapacke \
      libopenblas-base \
      libpng12-0 \
      # zmeventnotification dependencies
      git-core \
      wget \
    && \
    git clone --depth 1 "https://github.com/pliablepixels/mlapi" /mlapi && \
    /mlapi/get_models.sh && \
    # Cleanup
    apt-get remove -y \
      git-core \
      wget \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

WORKDIR ${APP_DIR}
CMD [ "python3", "./mlapi.py", "-c", "./mlapiconfig.ini" ]

VOLUME [ "/var/lib/zmeventnotification/images", "/var/lib/zmeventnotification/known_faces", "/var/lib/zmeventnotification/unknown_faces" ]
EXPOSE 9000