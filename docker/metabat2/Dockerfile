FROM debian:10.2

ENV LANG=C.UTF-8

ENV VERSION=2.12.1

RUN apt-get update

RUN apt-get -y install \
  curl

RUN mkdir -p /usr/local/metabat2
WORKDIR /usr/local/metabat2
RUN curl -s -L https://bitbucket.org/berkeleylab/metabat/downloads/metabat-static-binary-linux-x64_v${VERSION}.tar.gz | \
    tar -zxf - --strip-components=1
    
# metabat2 excutables are not r-x for all, this causes problems in azure/shipyard
RUN chmod +rx \
  metabat* \
  runMetaBat.sh \
  jgi_summarize_bam_contig_depths \
  contigOverlaps \
  aggregateContigOverlapsByBin.pl \
  aggregateBinDepths.pl  
WORKDIR /
ENV PATH="/usr/local/metabat2:${PATH}"

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*
