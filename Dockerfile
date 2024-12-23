FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive 

RUN \
    apt -y update && \
    apt -y upgrade && \
    apt -y install \
    autoconf automake autopoint bash bison build-essential bzip2 flex \ 
    g++ gettext git gperf intltool iputils-ping libffi-dev libgdk-pixbuf2.0-dev libltdl-dev libssl-dev \
    libgl-dev libpcre3-dev libtool-bin libxml-parser-perl lzip make nano openssl p7zip-full patch perl \
    python3 python3-mako python3-packaging python3-pkg-resources python-is-python3 python3-setuptools \
    ruby scons sed sqlite3 unzip wget xz-utils && \
    apt -y autoremove && \
    apt -y autoclean && \
    apt -y clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
    cd /opt && \
    git clone https://github.com/mxe/mxe.git

ENV PATH="${PATH}:/opt/mxe/usr/bin"

RUN \
    cd /opt/mxe && \
    make download-qt6-qtbase && \
    make --jobs=$(nproc) JOBS=$(nproc) MXE_TARGETS='x86_64-w64-mingw32.static' qt6-qtbase

ENV PATH="${PATH}:/opt/mxe/usr/x86_64-w64-mingw32.static/qt6/bin"

RUN ln -s /opt/mxe/usr/bin/x86_64-w64-mingw32.static-cmake /usr/local/bin/cmake 

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "-c", "cd /app && mkdir -p build && cd build && cmake \
    -DCMAKE_CXX_FLAGS=\"\
    -DENV_SPECIFIC_FONT=\\\\\\\"${CUSTOM_FONT}\\\\\\\" \
    -DENV_USER_DATA_PATH=\\\\\\\"${USER_DATA_PATH}\\\\\\\" \
    -DENV_DEFAULT_JSON_PATH=\\\\\\\"${DEFAULT_JSON_PATH}\\\\\\\" \
    -DENV_CUSTOM_DATA_PATH=\\\\\\\"${CUSTOM_DATA_PATH}\\\\\\\"\" \
    -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc)"]
