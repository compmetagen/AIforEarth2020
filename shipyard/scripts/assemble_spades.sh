# assemble.sh SRA_ACCESSION

#### Parameters:
THREADS=32
MEMORY=350
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
FASTQ_CLEAN_DIR=${SAMPLES_DIR}/${1}/fastq_clean
DATA_DIR=${SAMPLES_DIR}/${1}/data/spades
LOG_DIR=${SAMPLES_DIR}/${1}/logs/spades

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}
cp ${FASTQ_CLEAN_DIR}/*.fastq .

if [ -f "${1}_2.fastq" ]; then
    spades.py \
        --meta \
        --only-assembler \
        -1 ${1}_1.fastq \
        -2 ${1}_2.fastq  \
        --threads $THREADS \
        --memory $MEMORY \
        -o spades

    cp -r spades/. ${DATA_DIR}
    rm -r spades
fi

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
