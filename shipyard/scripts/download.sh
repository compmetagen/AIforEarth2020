# download.sh SRA_ACCESSION

#### Parameters:
THREADS=8
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
DATA_DIR=${SAMPLES_DIR}/${1}/data/fastq
LOG_DIR=${SAMPLES_DIR}/${1}/logs/download

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

fasterq-dump ${1} --threads $THREADS -O .
cp ${1}*.fastq ${DATA_DIR}
rm -rf ${1}*.fastq

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
