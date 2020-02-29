FROM debian:10.2

ENV LANG=C.UTF-8

ENV VERSION=1.2.9

RUN apt-get update

RUN apt-get -y install \
  curl \
  python \
  bzip2 \
  gzip \
  libgomp1

RUN mkdir -p /usr/local/megahit
WORKDIR /usr/local/megahit
RUN curl -s -L https://github.com/voutcn/megahit/releases/download/v${VERSION}/MEGAHIT-${VERSION}-Linux-x86_64-static.tar.gz | \
    tar -zxf - --strip-components=1
WORKDIR /
ENV PATH="/usr/local/megahit/bin:${PATH}"

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
