# map_bowtie.sh SRA_ACCESSION

#### Parameters:
THREADS=40
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
FASTQ_CLEAN_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean
SPADES_DATA_DIR=${SAMPLES_DIR}/${1}/data/spades
MEGAHIT_DATA_DIR=${SAMPLES_DIR}/${1}/data/megahit

DATA_DIR=${SAMPLES_DIR}/${1}/data/map
LOG_DIR=${SAMPLES_DIR}/${1}/logs/map/bowtie2

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}


if [ -f "${DATA_DIR}/map.sam" ] | [ -f "${DATA_DIR}/map.bam" ]; then
    exit 0
fi

if [ -f "${SPADES_DATA_DIR}/scaffolds.fasta" ]; then
    cp ${SPADES_DATA_DIR}/scaffolds.fasta contigs.fasta
elif [ -f "${MEGAHIT_DATA_DIR}/final.contigs.fa" ]; then
    cp ${MEGAHIT_DATA_DIR}/final.contigs.fa contigs.fasta
else
    >&2 echo "No contigs available"
    exit 1
fi

mkdir -p bowtie2db
bowtie2-build --threads $THREADS contigs.fasta bowtie2db/contigs

cp ${FASTQ_CLEAN_DIR}/*.fastq .
if [ -f "${1}_2.fastq" ]; then  
    bowtie2 -x bowtie2db/contigs -1 ${1}_1.fastq -2 ${1}_2.fastq --threads $THREADS -S map.sam
elif [ -f "${1}.fastq" ]; then 
    bowtie2 -x bowtie2db/contigs -U ${1}.fastq --threads $THREADS -S map.sam
else
    >&2 echo "No FASTQ files available"
    exit 1
fi

cp map.sam ${DATA_DIR}
rm -rf ${1}*.fastq
rm -rf map.sam
rm -rf contigs.fasta
rm -rf bowtiedb

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
