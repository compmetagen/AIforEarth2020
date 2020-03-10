# prok_qual.sh SRA_ACCESSION

#### Parameters:
THREADS=32
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
METABAT2_DATA_DIR=${SAMPLES_DIR}/${1}/data/metabat2

DATA_DIR=${SAMPLES_DIR}/${1}/data/checkm
LOG_DIR=${SAMPLES_DIR}/${1}/logs/checkm

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}


if [ -f "${DATA_DIR}/qa.txt" ]; then
    exit 0
fi

cp -r ${METABAT2_DATA_DIR}/bins/ .

checkm lineage_wf -t $THREADS -x fa bins checkm
checkm qa -t $THREADS checkm/lineage.ms checkm -o 2 -f checkm/qa.txt

cp -r checkm/. ${DATA_DIR}
rm -rf bins checkm

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
