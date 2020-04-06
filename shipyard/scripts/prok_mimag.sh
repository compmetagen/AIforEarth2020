# prok_mimag.sh SRA_ACCESSION

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/data/samples
METABAT2_DATA_DIR=${SAMPLES_DIR}/${1}/data/metabat2
CHECKM_DATA_DIR=${SAMPLES_DIR}/${1}/data/checkm

DATA_DIR=${SAMPLES_DIR}/${1}/data/checkm_mimag
LOG_DIR=${SAMPLES_DIR}/${1}/logs/checkm_mimag


if [ "$CLEAN" = 'true' ]; then
    rm -rf ${DATA_DIR} ${LOG_DIR}
fi

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

python3 checkm_mimag.py ${METABAT2_DATA_DIR}/bins ${CHECKM_DATA_DIR}/qa.txt \
    $DATA_DIR

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
