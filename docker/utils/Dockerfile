FROM debian:10.2

ENV LANG=C.UTF-8

RUN apt-get update

RUN apt-get -y install \
  curl \
  wget \
  bzip2 \
  gzip \
  python3 \
  python3-pip \
  build-essential

# for pysam
RUN apt-get -y install \
  libbz2-dev \
  zlib1g-dev \
  liblzma-dev
RUN pip3 install Cython

RUN pip3 install \
  numpy \
  scipy \
  pandas \
  matplotlib \
  biopython \
  pysam \
  matplotlib

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
