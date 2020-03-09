FROM debian:10.2

ENV LANG=C.UTF-8

ENV PRODIGAL_VERSION=1:2.6.3-4
ENV HMMER_VERSION=3.2.1+dfsg-1
ENV PPLACER_VERSION=1.1.alpha19
ENV FASTANI_VERSION=1.3
ENV FASTTREE_VERSION=2.1.10-2

# gtdbtk version
ENV VERSION=1.0.2

RUN apt-get update

RUN apt-get -y install \
  curl \
  unzip \
  python3 \
  python3-pip \
  build-essential \
  prodigal=${PRODIGAL_VERSION} \
  hmmer=${HMMER_VERSION} \
  fasttree=${FASTTREE_VERSION}

# install pplacer
RUN mkdir -p /usr/local/pplacer
WORKDIR /usr/local/pplacer
RUN curl -s -L https://github.com/matsen/pplacer/releases/download/v${PPLACER_VERSION}/pplacer-linux-v${PPLACER_VERSION}.zip -o pplacer.zip; \
    unzip -j pplacer.zip; \
    rm -rf pplacer.zip
WORKDIR /
ENV PATH="/usr/local/pplacer:${PATH}"

# install fastani
RUN mkdir -p /usr/local/fastani
WORKDIR /usr/local/fastani
RUN curl -s -L https://github.com/ParBLiSS/FastANI/releases/download/v${FASTANI_VERSION}/fastANI-Linux64-v${FASTANI_VERSION}.zip -o fastani.zip; \
    unzip -j fastani.zip; \
    rm -rf fastani.zip
WORKDIR /
ENV PATH="/usr/local/fastani:${PATH}"

RUN pip3 install numpy scipy matplotlib dendropy
RUN pip3 install gtdbtk

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
