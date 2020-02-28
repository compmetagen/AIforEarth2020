FROM debian:10.2

ENV LANG=C.UTF-8

ENV VERSION=2.9.2

RUN apt-get update
RUN apt-get -y install \
  libxml-libxml-perl \
  curl

RUN mkdir -p /usr/local/ncbi/sra-toolkit
WORKDIR /usr/local/ncbi/sra-toolkit
RUN curl -s https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${VERSION}/sratoolkit.${VERSION}-ubuntu64.tar.gz | \
    tar -zxf - --strip-components=1
WORKDIR /
ENV PATH="/usr/local/ncbi/sra-toolkit/bin:${PATH}"

RUN rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*