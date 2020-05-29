ACCESSION=${1}

MAX_MEMORY_GB=4
MIN_READ_LEN=50
KEEP_RAW_READS=1
KEEP_CLEAN_READS=1
WORKDIR="work"
OUTDIR=${ACCESSION}


######## START Preparation
mkdir ${WORKDIR}
mkdir ${OUTDIR}
######## END Preparation



######## START Download
# THREADS=6
# OUTDIR_RAW_READS=${OUTDIR}/raw_reads
# mkdir ${OUTDIR_RAW_READS}

# fasterq-dump ${ACCESSION} --threads $THREADS -O .

# if [ KEEP_RAW_READS ]; then   
#     cp ${ACCESSION}*.fastq ${OUTDIR_RAW_READS}
# fi
######## END Download



[ -f "${ACCESSION}_2.fastq" ]
SINGLE_END=$?



######## START Raw reads hist
OUTDIR_RAW_READS_HIST=${OUTDIR}/raw_reads_hist
mkdir ${OUTDIR_RAW_READS_HIST}

if [ SINGLE_END ]; then
    RAW_READS="in=\"${ACCESSION}.fastq\"" 
else    
    RAW_READS="in1=\"${ACCESSION}_1.fastq\" in2=\"${ACCESSION}_2.fastq\""
fi

bbduk.sh \
    -Xmx${MAX_MEMORY_GB}g \
    ${RAW_READS} \
    bhist=bhist.txt \
    qhist=qhist.txt \
    gchist=gchist.txt \
    aqhist=aqhist.txt \
    lhist=lhist.txt \
    gcbins=auto

mv *hist.txt ${OUTDIR_RAW_READS_HIST}
######## END Raw reads histograms



######## START Clean reads
THREADS=6
OUTDIR_CLEAN_READS=${OUTDIR}/clean_reads
mkdir ${OUTDIR_CLEAN_READS}

if [ SINGLE_END ]; then
    RAW_READS="in=\"${ACCESSION}.fastq\""
    CLEAN_ADAPTER_READS="out=clean_adapter.fastq"
    CLEAN_CONTAMINANT_READS="out=clean_contaminant.fastq"
    CLEAN_READS="out=\"${ACCESSION}_clean.fastq\""
else    
    RAW_READS="in1=\"${ACCESSION}_1.fastq\" in2=\"${ACCESSION}_2.fastq\""
    CLEAN_ADAPTER_READS="out1=clean_adapter_1.fastq out2=clean_adapter_2.fastq"
    CLEAN_CONTAMINANT_READS="out1=clean_contaminant_1.fastq out2=clean_contaminant_2.fastq"
    CLEAN_READS="out1=\"${ACCESSION}_clean_1.fastq\" out2=\"${ACCESSION}_clean_2.fastq\""
fi

bbduk.sh \
    -Xmx${MAX_MEMORY_GB}g \
    $RAW_READS \
    $CLEAN_ADAPTER_READS \
    ref=adapters \
    ktrim=r \
    k=23 \
    mink=11 \
    hdist=1 \
    tpe \
    tbo \
    interleaved=f \
    stats=stats_adapter_trimming.txt
    threads=$THREADS

rm -rf ${ACCESSION}*.fastq

bbduk.sh \
    -Xmx${MAX_MEMORY_GB}g \
    $CLEAN_ADAPTER_READS \
    $CLEAN_CONTAMINANT_READS \
    ref=artifacts,phix \
    k=31 \
    hdist=1 \
    interleaved=f \
    stats=stats_contaminant_filtering.txt \
    threads=$THREADS

rm -rf clean_adapter*.fastq

bbduk.sh \
    $CLEAN_CONTAMINANT_READS \
    $CLEAN_READS \
    maq=10 \
    maxns=4 \
    qtrim=r \
    trimq=6 \
    mlf=0.5 \
    minlen=$MIN_READ_LEN \
    interleaved=f \
    threads=$THREADS

rm -rf clean_contaminant*.fastq

if [ KEEP_CLEAN_READS ]; then   
    cp ${ACCESSION}_clean*.fastq ${OUTDIR_CLEAN_READS}
fi
######## END Clean reads



######## START Clean reads hist
OUTDIR_CLEAN_READS_HIST=${OUTDIR}/clean_reads_hist
mkdir ${OUTDIR_CLEAN_READS_HIST}

if [ SINGLE_END ]; then
    CLEAN_READS="in=\"${ACCESSION}_clean.fastq\""
else    
    CLEAN_READS="in1=\"${ACCESSION}_clean_1.fastq\" in2=\"${ACCESSION}_clean_2.fastq\""
fi

bbduk.sh \
    -Xmx${MAX_MEMORY_GB}g \
    ${CLEAN_READS} \
    bhist=bhist.txt \
    qhist=qhist.txt \
    gchist=gchist.txt \
    aqhist=aqhist.txt \
    lhist=lhist.txt \
    gcbins=auto

mv *hist.txt ${OUTDIR_CLEAN_READS_HIST}
######## END Clean reads histograms



######## START Spades
THREADS=14

SPADES_FAILED=0
if [ ! SINGLE_END ]; then
    OUTDIR_SPADES=${OUTDIR}/spades
    mkdir ${OUTDIR_SPADES}

    set +e
    trap 'SPADES_FAILED=1' ERR
    spades.py \
        --meta \
        --only-assembler \
        -1 ${ACCESSION}_clean_1.fastq \
        -2 ${ACCESSION}_clean_2.fastq \
        --threads $THREADS \
        --memory $MAX_MEMORY_GB \
        -o spades
    set -e

    if [ ! SPADES_FAILED ]; then
        cp \
            spades/scaffolds.fasta \
            spades/contigs.fasta \
            spades/spades.log \
            ${OUTDIR_SPADES}

        cp \
            spades/scaffolds.fasta \
            ${OUTDIR}/${ACCESSION}_scaffolds.fasta
        echo "SPADES" > ${OUTDIR}/assembly_readme.txt

        rm -rf spades
    fi

######## END Spades



######## START Megahit
THREADS=14

if [ SINGLE_END ] || [ SPADES_FAILED]; then
    OUTDIR_MEGAHIT=${OUTDIR}/megahit
    mkdir ${OUTDIR_MEGAHIT}

    if [ SINGLE_END ]; then
        CLEAN_READS="-r \"${ACCESSION}_clean.fastq\""
    else
        CLEAN_READS="-1 \"${ACCESSION}_clean_1.fastq\" -2 \"${ACCESSION}_clean_2.fastq\""
    fi

    megahit \
        ${CLEAN_READS} \
        -t ${THREADS} \
        --k-min 27 \
        --k-max 99 \
        --k-step 14 \
        --kmin-1pass \
        --memory $MAX_MEMORY_GB \
        -o megahit &> megahit.log

    cp \
        megahit/final.contigs.fa \
        megahit.log \
        $OUTDIR_MEGAHIT

    cp \
        megahit/final.contigs.fa \
        ${OUTDIR}/${ACCESSION}_scaffolds.fasta
    echo "MEGAHIT" > ${OUTDIR}/assembly_readme.txt
    
    rm -rf megahit megahit.log
######## END Megahit


######## START Assembly stats
stats.sh \
    in=${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    out=${OUTDIR}/${ACCESSION}_scaffolds_stats.txt
######## END Assembly stats


######## START Mapping
THREADS=8

mkdir -p bowtie2db
bowtie2-build \
    --threads $THREADS \
    ${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    bowtie2db/contigs

if [ SINGLE_END ]; then
    CLEAN_READS="-U \"${ACCESSION}_clean.fastq\""
else
    CLEAN_READS="-1 \"${ACCESSION}_clean_1.fastq\" -2 \"${ACCESSION}_clean_2.fastq\""
fi

bowtie2 \
    -x bowtie2db/contigs \
    ${CLEAN_READS} \
    --threads $THREADS \
    -S map.sam

rm -rf bowtie2db
######## END Mapping



rm -rf ${ACCESSION}_clean*.fastq



######## START Samtools
THREADS=8
MAX_MEM_PER_THREAD=12

samtools sort -@ ${THREADS} -m ${MAX_MEM_PER_THREAD} -o map.bam map.sam

rm -rf map.sam
######## END Samtools


######## START Metabat
THREADS=8

mkdir -p ${OUTDIR}/bins

jgi_summarize_bam_contig_depths --outputDepth depth.txt map.bam
metabat2 \
    -i ${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    -a ${OUTDIR}/depth.txt \
    -o ${OUTDIR}/bins/${ACCESSION}.bin \
    -v \
    -t $THREADS \
    -m 2500 &> ${OUTDIR}/metabat.log

rm -rf map.bam
######## END Metabat



######## START Checkm
THREADS=8

checkm lineage_wf -t $THREADS -x fa ${OUTDIR}/bins checkm
checkm qa -t $THREADS checkm/lineage.ms checkm -o 2 -f ${OUTDIR}/checkm_qa.txt

rm -rf checkm
######## END Checkm



######## START MIMAG
python3 checkm_mimag.py ${OUTDIR}/bins \
    ${OUTDIR}/checkm_qa.txt \
    ${OUTDIR}/mimag_prok
######## END MIMAG