# download.sh SRA_ACCESSION

#### Parameters:
THREADS=1
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/data/samples
DATA_DIR=${SAMPLES_DIR}/${1}/data/fastq
LOG_DIR=${SAMPLES_DIR}/${1}/logs/download


if [ "$CLEAN" = 'true' ]; then
    rm -rf ${DATA_DIR} ${LOG_DIR}
fi

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

if [ -f "${DATA_DIR}/${1}.fastq" ] || [ -f "${DATA_DIR}/${1}_2.fastq" ] ; then
    exit 0
fi

fasterq-dump ${1} --threads $THREADS -O .
cp ${1}*.fastq ${DATA_DIR}
rm -rf ${1}*.fastq

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
