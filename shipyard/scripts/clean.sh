# clean.sh SRA_ACCESSION

# For BBMap parameters see http://seqanswers.com/forums/showthread.php?t=42776,
# https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/data-preprocessing/,
# and assemblyPipeline.sh in the BBMap package

#### Parameters:
THREADS=42
MINLENGTH=120 
#### End Parameters

SAMPLES_DIR=${AZ_BATCH_NODE_SHARED_DIR}/aiforearth/samples
FASTQ_DIR=${SAMPLES_DIR}/${1}/data/fastq
DATA_DIR=${SAMPLES_DIR}/${1}/data/fastq_clean
LOG_DIR=${SAMPLES_DIR}/${1}/logs/fastq_clean

mkdir -p ${DATA_DIR}
mkdir -p ${LOG_DIR}

cp ${FASTQ_DIR}/*.fastq .

if [ -f "${1}_2.fastq" ]; then
    # Paired-end. Do not consider unmated reads (*_3.fastq).

    bbduk.sh \
        in1=${1}_1.fastq \
        in2=${1}_2.fastq \
        out1=noadapt_1.fastq \
        out2=noadapt_2.fastq \
        ref=adapters \
        ktrim=r \
        k=23 \
        mink=11 \
        hdist=1 \
        tpe \
        tbo \
        interleaved=f \
        threads=$THREADS
    rm ${1}_?.fastq

    bbduk.sh \
        in1=noadapt_1.fastq \
        in2=noadapt_2.fastq \
        out1=nocont_1.fastq \
        out2=nocont_2.fastq \
        ref=artifacts,phix \
        k=31 \
        hdist=1 \
        interleaved=f \
        threads=$THREADS
    rm noadapt_?.fastq

    bbduk.sh \
        in1=nocont_1.fastq \
        in2=nocont_2.fastq \
        out1=${1}_1.fastq \
        out2=${1}_2.fastq \
        minavgquality=3 \
        maxns=4 \
        qtrim=r \
        trimq=6 \
        mlf=0.5 \
        minlength=$MINLENGTH \
        interleaved=f \
        threads=$THREADS
    rm nocont_?.fastq
else 
    # single-end

    bbduk.sh \
        in=${1}.fastq \
        out=noadapt.fastq \
        ref=adapters \
        ktrim=r \
        k=23 \
        mink=11 \
        hdist=1 \
        tpe \
        tbo \
        interleaved=f \
        threads=$THREADS
    rm ${1}.fastq

    bbduk.sh \
        in=noadapt.fastq \
        out=nocont.fastq \
        ref=artifacts,phix \
        k=31 \
        hdist=1 \
        interleaved=f \
        threads=$THREADS
    rm noadapt.fastq

    bbduk.sh \
        in=nocont.fastq \
        out=${1}.fastq \
        minavgquality=3 \
        maxns=4 \
        qtrim=r \
        trimq=6 \
        mlf=0.5 \
        minlength=$MINLENGTH \
        interleaved=f \
        threads=$THREADS
    rm nocont.fastq
fi

cp ${1}*.fastq ${DATA_DIR}
rm -rf ${1}*.fastq

# copy logs
cp ${AZ_BATCH_TASK_DIR}/std???.txt ${LOG_DIR}
