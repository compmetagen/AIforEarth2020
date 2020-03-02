# bin.sh SRA_ACCESSION

#### Parameters:
THREADS=40
MIN_CONTIG_SIZE=2500
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
MAP_DATA_DIR=${SAMPLES_DIR}/${1}/data/map
SPADES_DATA_DIR=${SAMPLES_DIR}/${1}/data/spades
MEGAHIT_DATA_DIR=${SAMPLES_DIR}/${1}/data/megahit

DATA_DIR=${SAMPLES_DIR}/${1}/data/metabat2
LOG_DIR=${SAMPLES_DIR}/${1}/logs/metabat2

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}


if [ -d "${DATA_DIR}/bins" ]; then
    exit 0
fi

if [ -f "${SPADES_DATA_DIR}/scaffolds.fasta" ]; then
    cp ${SPADES_DATA_DIR}/scaffolds.fasta contigs.fasta
elif [ -f "${MEGAHIT_DATA_DIR}/final.contigs.fa" ]; then
    cp ${MEGAHIT_DATA_DIR}/final.contigs.fa contigs.fasta
else
    >&2 echo "No contigs available"
    exit 1
fi

cp ${MAP_DATA_DIR}/map.bam .
mkdir -p bins

jgi_summarize_bam_contig_depths --outputDepth depth.txt map.bam
metabat2 -i contigs.fasta -a depth.txt -o bins/${1} -v -t $THREADS -m $MIN_CONTIG_SIZE

cp -r bins ${DATA_DIR}
cp depth.txt ${DATA_DIR}

rm -rf contigs.fasta
rm -rf map.bam
rm -rf depth.txt
rm -rf bins

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
