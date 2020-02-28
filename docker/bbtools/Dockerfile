FROM debian:10.2

ENV LANG=C.UTF-8

ENV VERSION=38.79

RUN apt-get update
RUN apt-get -y install \
  default-jre \
  curl

RUN mkdir -p /usr/local/bbmap
WORKDIR /usr/local/bbmap
RUN curl -s -L https://sourceforge.net/projects/bbmap/files/BBMap_${VERSION}.tar.gz/download | \
    tar -zxf - --strip-components=1
WORKDIR /
ENV PATH="/usr/local/bbmap:${PATH}"

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*