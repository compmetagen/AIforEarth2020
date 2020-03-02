# map_samtools.sh SRA_ACCESSION

#### Parameters:
THREADS=24
MAX_MEM_PER_THREAD=8G # remember the G suffix (for giga)
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
FASTQ_CLEAN_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean

DATA_DIR=${SAMPLES_DIR}/${1}/data/map/
LOG_DIR=${SAMPLES_DIR}/${1}/logs/map/samtools

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}


if [ -f "${DATA_DIR}/map.bam" ]; then
    exit 0
fi

cp $OUT_DIR/map.sam .
samtools sort -@ ${THREADS} -m ${MAX_MEM_PER_THREAD} -o map.bam map.sam
rm -rf map.sam
rm -rf $OUT_DIR/map.sam
cp map.bam ${DATA_DIR}

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
