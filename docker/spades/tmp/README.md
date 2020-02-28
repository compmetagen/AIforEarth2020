# sra-toolkit

## fasterq-dump example

```sh
docker run --rm sra-toolkit fasterq-dump SRR11115845 --threads 2 -O /tmp
```

For spots having 1 read, the reads are written into the *.fastq file. For spots
having 2 reads, the reads are written into the *_1.fastq and *_2.fastq files.
Unmated reads (if present) are placed in *_3.fastq