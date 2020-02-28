# assemble.sh SRA_ACCESSION

#### Parameters:
THREADS=1
MEMORY=300
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples

mkdir -p ${SAMPLES_DIR}/${1}/logs
mkdir -p ${SAMPLES_DIR}/${1}/logs/assemble
mkdir -p ${SAMPLES_DIR}/${1}/spades

cp ${SAMPLES_DIR}/${1}/fastq_clean/*.fastq .

if [ -f "${1}_2.fastq" ]; then
    spades.py \
        --meta \
        --only-assembler \
        -1 ${SAMPLES_DIR}_1.fastq \
        -2 ${SAMPLES_DIR}_2.fastq  \
        --threads $THREADS \
        --memory $MEMORY \
        -o spades

    cp -r spades/. ${SAMPLES_DIR}/${1}/spades
    rm -r spades
fi

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${SAMPLES_DIR}/${1}/logs/assemble
