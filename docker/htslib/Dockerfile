FROM debian:10.2

ENV LANG=C.UTF-8

ENV SAMTOOLS_VERSION=1.9-4
ENV TABIX_VERSION=1.9-11
ENV BCFTOOLS_VERSION=1.9-1

RUN apt-get update

RUN apt-get -y install \
  samtools=${SAMTOOLS_VERSION} \
  tabix=${TABIX_VERSION} \
  bcftools=${BCFTOOLS_VERSION}

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
