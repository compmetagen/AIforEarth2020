# assemble.sh SRA_ACCESSION

#### Parameters:
THREADS=40
MEMORY=0.8 # fraction available memory
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
FASTQ_CLEAN_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean
DATA_DIR=${SAMPLES_DIR}/${1}/data/megahit
LOG_DIR=${SAMPLES_DIR}/${1}/logs/megahit
SPADES_DATA_DIR=${SAMPLES_DIR}/${1}/data/spades

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}


if [ -f "${FASTQ_CLEAN_DIR}/${1}_2.fastq" ] && \
   [ ! -f "${SPADES_DATA_DIR}/scaffolds.fasta" ]; then
    # paired-end but skipped by spades

    cp ${FASTQ_CLEAN_DIR}/*.fastq .

    megahit \
        -1 ${1}_1.fastq \
        -2 ${1}_2.fastq  \
        -t $THREADS \
        --k-min 27 \
        --k-max 98 \
        --k-step 14 \
        --kmin-1pass \
        --memory $MEMORY \
        -o megahit

    cp -r megahit/. ${DATA_DIR}
    rm -r megahit
    rm -rf ${1}*.fastq

elif [ -f "${FASTQ_CLEAN_DIR}/${1}.fastq" ]; then 
    # single-end

    cp ${FASTQ_CLEAN_DIR}/${1}.fastq .

    megahit \
        -r ${1}.fastq \
        -t $THREADS \
        --k-min 27 \
        --k-max 98 \
        --k-step 14 \
        --kmin-1pass \
        --memory $MEMORY \
        -o megahit

    cp -r megahit/. ${DATA_DIR}
    rm -r megahit
    rm -rf ${1}.fastq
else
    echo "SKIPPED"
fi

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
