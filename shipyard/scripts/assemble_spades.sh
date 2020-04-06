# assemble.sh SRA_ACCESSION

#### Parameters:
THREADS=28
MEMORY=240 # in GB
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/data/samples
FASTQ_CLEAN_DATA_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean

DATA_DIR=${SAMPLES_DIR}/${1}/data/spades
LOG_DIR=${SAMPLES_DIR}/${1}/logs/spades


if [ "$CLEAN" = 'true' ]; then
    rm -rf ${DATA_DIR} ${LOG_DIR}
fi

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

if [ -f "${DATA_DIR}/scaffolds.fasta" ]; then
    exit 0
fi

cp ${FASTQ_CLEAN_DATA_DIR}/*.fastq .

if [ -f "${FASTQ_CLEAN_DATA_DIR}/${1}_2.fastq" ]; then

    cp ${FASTQ_CLEAN_DATA_DIR}/*.fastq .

    spades.py \
        --meta \
        --only-assembler \
        -1 ${1}_1.fastq \
        -2 ${1}_2.fastq  \
        -k 21,33,55,77,99 \
        --threads $THREADS \
        --memory $MEMORY \
        -o spades

    cp -r spades/. ${DATA_DIR}
    rm -rf spades
    rm -rf ${1}*.fastq
else
    echo "SKIPPED"
fi

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
