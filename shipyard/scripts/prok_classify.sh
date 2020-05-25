# prok_qual.sh SRA_ACCESSION

#### Parameters:
THREADS=14
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/data/samples
CHECKM_MIMAG_DIR=${SAMPLES_DIR}/${1}/data/checkm_mimag

DATA_DIR=${SAMPLES_DIR}/${1}/data/gtdbtk
LOG_DIR=${SAMPLES_DIR}/${1}/logs/gtdbtk


if [ "$CLEAN" = 'true' ]; then
    rm -rf ${DATA_DIR} ${LOG_DIR}
fi

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

if [ -f "${DATA_DIR}/${1}.bac120.summary.tsv" ] || [ -f "${DATA_DIR}/${1}.ar122.summary.tsv" ]; then
    exit 0
fi

cp -r ${CHECKM_MIMAG_DIR}/MQ .
mkdir gtdbtk
gtdbtk classify_wf --cpus $THREADS --genome_dir MQ --prefix ${1} --out_dir gtdbtk/MQ

cp -r ${CHECKM_MIMAG_DIR}/HQ .
mkdir gtdbtk
gtdbtk classify_wf --cpus $THREADS --genome_dir HQ --prefix ${1} --out_dir gtdbtk/HQ

cp -r gtdbtk/. ${DATA_DIR}
rm -rf MQ HQ gtdbtk

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
