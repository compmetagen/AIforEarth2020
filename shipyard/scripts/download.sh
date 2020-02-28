# download.sh SRA_ACCESSION

#### Parameters:
THREADS=1
#### End Parameters

mkdir -p ${SAMPLES_DIR}/${1}/logs
mkdir -p ${SAMPLES_DIR}/${1}/logs/download
mkdir -p ${SAMPLES_DIR}/${1}/fastq

fasterq-dump ${1} --threads $THREADS -O .
cp ${1}*.fastq ${SAMPLES_DIR}/${1}/fastq
rm -rf ${1}*.fastq

# copy logs
cp ${AZ_BATCH_TASK_WORKING_DIR}/std???.txt ${SAMPLES_DIR}/${1}/logs/download
