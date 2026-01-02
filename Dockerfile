#syntax=docker/dockerfile:1
FROM debian:bookworm-slim

LABEL maintainer="magne4000"

ENV DEBIAN_FRONTEND=noninteractive
ENV STARBOUND_HOME=/home/starbound
ENV STARBOUND_OPENSTARBOUND=$STARBOUND_HOME/openStarbound

# Install UTF8 locale
RUN apt-get update && apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Install required libraries in one layer
RUN dpkg --add-architecture i386 && \
    apt-get install -y --no-install-recommends \
        gosu \
        wget \
        curl \
        unzip \
        ca-certificates \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6-i386 \
        libcurl4 \
        libvorbisfile3 \
        libstdc++6 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 1000 starbound && \
    adduser --disabled-password --gecos "" --uid 1000 --gid 1000 starbound
WORKDIR $STARBOUND_HOME

# Copy entrypoint script
COPY --chown=starbound:starbound --chmod=0755 entry.sh /entry.sh
COPY --chown=starbound:starbound --chmod=0755 start.sh /start.sh

EXPOSE 21025/tcp

ENTRYPOINT ["/entry.sh"]
