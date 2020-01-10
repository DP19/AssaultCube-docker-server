FROM debian:jessie-slim as builder

ENV ACVERSION=1.2.0.2
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /assaultcube

RUN apt-get update && \
    apt-get install -y bzip2 gcc make clang zlib1g-dev curl && \
    curl -LJO https://github.com/assaultcube/AC/archive/v$ACVERSION.tar.gz && \
    tar -xvf AC-$ACVERSION.tar.gz && \
    mv AC-$ACVERSION source && \
    curl -LJO https://github.com/assaultcube/AC/releases/download/v$ACVERSION/AssaultCube_v$ACVERSION.tar.bz2 && \
    tar -xvjf AssaultCube_v$ACVERSION.tar.bz2 && \
    mv AssaultCube_v$ACVERSION ac  && \
    cd /assaultcube/source/ && \
    mkdir bin_unix && \
    cd bin_unix && \
    mkdir native_server && \
    cd /assaultcube/source/source/enet && \
    sh ./configure -build=x86-linux -host=arm-unknown-linux-gnueabi && \
    make clean && \
    make && \
    make install && \
    cd /assaultcube/source/source/src && \
    make server_install && \
    cp -R /assaultcube/source/bin_unix/native_server/ac_server /assaultcube/ac/bin_unix/native_server

FROM debian:jessie-slim

WORKDIR /assaultcube

COPY --from=builder /assaultcube/ac /assaultcube/ac
COPY --from=builder /usr/local/lib/libenet.so.2.1.0 /usr/local/lib/libenet.so.2.1.0

RUN apt-get update && \
    apt-get install -y libsdl1.2debian libsdl-image1.2 zlib1g libogg0 libvorbis0a libopenal1 curl && \
    ln -s /usr/local/lib/libenet.so.2.1.0 /usr/lib/libenet.so.2 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /assaultcube/ac/

CMD ["./server.sh"]