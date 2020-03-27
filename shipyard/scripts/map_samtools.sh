# map_samtools.sh SRA_ACCESSION

#### Parameters:
THREADS=24
MAX_MEM_PER_THREAD=8G # remember the G suffix (for giga)
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/data/samples
FASTQ_CLEAN_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean

DATA_DIR=${SAMPLES_DIR}/${1}/data/map_bowtie2
LOG_DIR=${SAMPLES_DIR}/${1}/logs/map_bowtie2


mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

if [ -f "${DATA_DIR}/map.bam" ]; then
    exit 0
fi

cp ${DATA_DIR}/map.sam .
samtools sort -@ ${THREADS} -m ${MAX_MEM_PER_THREAD} -o map.bam map.sam
cp map.bam ${DATA_DIR}
rm -rf map.?am
rm -rf ${DATA_DIR}/map.sam

# copy logs
cp ${AZ_BATCH_TASK_DIR}/stdout.txt ${LOG_DIR}/stdout_samtools.txt
cp ${AZ_BATCH_TASK_DIR}/stderr.txt ${LOG_DIR}/stderr_samtools.txt
