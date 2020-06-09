######## ENVIRONMENT VARIABLES
# ACCESSION=sample
# MEM=4
# CPU_L=2
# CPU_M=4
# CPU_H=8
# MIN_READ_LEN=50
# KEEP_RAW_READS=0
# KEEP_CLEAN_READS=0


######## START Preparation
OUTDIR=${ACCESSION}
mkdir -p ${OUTDIR}
######## END Preparation


######## START Download
OUTDIR_RAW_READS=${OUTDIR}/raw_reads
mkdir -p ${OUTDIR_RAW_READS}

fasterq-dump ${ACCESSION} --threads $CPU_L -O .

if [ KEEP_RAW_READS ]; then   
    cp ${ACCESSION}*.fastq ${OUTDIR_RAW_READS}
fi
######## END Download


[ -f "${ACCESSION}_2.fastq" ]
SINGLE_END=$?


######## START Raw reads hist
OUTDIR_RAW_READS_HIST=${OUTDIR}/raw_reads_hist
mkdir -p ${OUTDIR_RAW_READS_HIST}

if (( $SINGLE_END )) ; then
    RAW_READS="in=\"${ACCESSION}.fastq\"" 
else    
    RAW_READS="in1=\"${ACCESSION}_1.fastq\" in2=\"${ACCESSION}_2.fastq\""
fi

bbduk.sh \
    -Xmx${MEM}g \
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
OUTDIR_CLEAN_READS=${OUTDIR}/clean_reads
OUTDIR_STATS_CLEAN=${OUTDIR}/stats_clean

mkdir -p ${OUTDIR_CLEAN_READS}
mkdir -p ${OUTDIR_STATS_CLEAN}

if (( $SINGLE_END )) ; then
    RAW_READS="in=\"${ACCESSION}.fastq\""
    CLEAN_ADAPTER_READS="out=clean_adapter.fastq"
else    
    RAW_READS="in1=\"${ACCESSION}_1.fastq\" in2=\"${ACCESSION}_2.fastq\""
    CLEAN_ADAPTER_READS="out1=clean_adapter_1.fastq out2=clean_adapter_2.fastq"
fi

bbduk.sh \
    -Xmx${MEM}g \
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
    threads=$CPU_M
rm -rf ${ACCESSION}*.fastq

if (( $SINGLE_END )) ; then
    CLEAN_ADAPTER_READS="in=clean_adapter.fastq"
    CLEAN_CONTAMINANT_READS="out=clean_contaminant.fastq"
else    
    CLEAN_ADAPTER_READS="in1=clean_adapter_1.fastq in2=clean_adapter_2.fastq"
    CLEAN_CONTAMINANT_READS="out1=clean_contaminant_1.fastq out2=clean_contaminant_2.fastq"
fi

bbduk.sh \
    -Xmx${MEM}g \
    $CLEAN_ADAPTER_READS \
    $CLEAN_CONTAMINANT_READS \
    ref=artifacts,phix \
    k=31 \
    hdist=1 \
    interleaved=f \
    stats=stats_contaminant_filtering.txt \
    threads=$CPU_M
rm -rf clean_adapter*.fastq

if (( $SINGLE_END )) ; then
    CLEAN_CONTAMINANT_READS="in=clean_contaminant.fastq"
    CLEAN_READS="out=\"${ACCESSION}_clean.fastq\""
else    
    CLEAN_CONTAMINANT_READS="in1=clean_contaminant_1.fastq in2=clean_contaminant_2.fastq"
    CLEAN_READS="out1=\"${ACCESSION}_clean_1.fastq\" out2=\"${ACCESSION}_clean_2.fastq\""
fi

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
    threads=$CPU_M
rm -rf clean_contaminant*.fastq

if (( $KEEP_CLEAN_READS )) ; then   
    cp ${ACCESSION}_clean*.fastq ${OUTDIR_CLEAN_READS}
fi

mv stats_adapter_trimming.txt $OUTDIR_STATS_CLEAN
mv stats_contaminant_filtering.txt $OUTDIR_STATS_CLEAN
######## END Clean reads


######## START Clean reads hist
OUTDIR_CLEAN_READS_HIST=${OUTDIR}/clean_reads_hist
mkdir -p ${OUTDIR_CLEAN_READS_HIST}

if (( $SINGLE_END )); then
    CLEAN_READS="in=\"${ACCESSION}_clean.fastq\""
else    
    CLEAN_READS="in1=\"${ACCESSION}_clean_1.fastq\" in2=\"${ACCESSION}_clean_2.fastq\""
fi

bbduk.sh \
    -Xmx${MEM}g \
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
SPADES_FAILED=0
if (( ! $SINGLE_END )); then
    OUTDIR_SPADES=${OUTDIR}/spades
    mkdir -p ${OUTDIR_SPADES}

    set +e
    trap 'SPADES_FAILED=1' ERR
    spades.py \
        --meta \
        --only-assembler \
        -1 ${ACCESSION}_clean_1.fastq \
        -2 ${ACCESSION}_clean_2.fastq \
        --threads $CPU_H \
        --memory $MEM \
        -o spades
    set -e

    if [ -e spades/spades.log ]; then 
        cp spades/spades.log ${OUTDIR_SPADES}
    fi

    if (( ! $SPADES_FAILED )); then
        cp spades/scaffolds.fasta spades/contigs.fasta \
            ${OUTDIR_SPADES}
        cp spades/scaffolds.fasta \
            ${OUTDIR}/${ACCESSION}_scaffolds.fasta
        echo "SPADES" > ${OUTDIR}/assembly_readme.txt
    fi

    rm -rf spades

fi
######## END Spades


######## START Megahit
if (( $SINGLE_END || $SPADES_FAILED )); then
    OUTDIR_MEGAHIT=${OUTDIR}/megahit
    mkdir -p ${OUTDIR_MEGAHIT}

    if (( $SINGLE_END )) ; then
        CLEAN_READS="-r ${ACCESSION}_clean.fastq"
    else
        CLEAN_READS="-1 ${ACCESSION}_clean_1.fastq -2 ${ACCESSION}_clean_2.fastq"
    fi

    megahit \
        ${CLEAN_READS} \
        -t $CPU_H \
        --k-min 27 \
        --k-max 99 \
        --k-step 14 \
        --kmin-1pass \
        --memory $MEM \
        -o megahit &> ${OUTDIR_MEGAHIT}/megahit.log

    cp megahit/final.contigs.fa $OUTDIR_MEGAHIT
    cp megahit/final.contigs.fa ${OUTDIR}/${ACCESSION}_scaffolds.fasta
    echo "MEGAHIT" > ${OUTDIR}/assembly_readme.txt   
    rm -rf megahit
fi
######## END Megahit


######## START Assembly stats
stats.sh \
    in=${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    out=${OUTDIR}/${ACCESSION}_scaffolds_stats.txt
######## END Assembly stats


######## START Mapping
mkdir -p bowtie2db
bowtie2-build \
    --threads $CPU_M \
    ${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    bowtie2db/contigs

if (( $SINGLE_END )) ; then
    CLEAN_READS="-U \"${ACCESSION}_clean.fastq\""
else
    CLEAN_READS="-1 \"${ACCESSION}_clean_1.fastq\" -2 \"${ACCESSION}_clean_2.fastq\""
fi

bowtie2 \
    -x bowtie2db/contigs \
    ${CLEAN_READS} \
    --threads $CPU_M \
    -S map.sam
rm -rf bowtie2db
######## END Mapping


rm -rf ${ACCESSION}_clean*.fastq


######## START Samtools
MEM_PER_THREAD=$(( MEM/CPU_M > 1 ? MEM/CPU_M : 1))G
samtools sort -@ $CPU_M -m $MEM_PER_THREAD -o map.bam map.sam
rm -rf map.sam
######## END Samtools


######## START Metabat2
mkdir -p ${OUTDIR}/bins
jgi_summarize_bam_contig_depths --outputDepth ${OUTDIR}/metabat2_depth.txt map.bam
metabat2 \
    -i ${OUTDIR}/${ACCESSION}_scaffolds.fasta \
    -a ${OUTDIR}/metabat2_depth.txt \
    -o ${OUTDIR}/bins/${ACCESSION}.bin \
    -v \
    -t $CPU_M \
    -m 2500 &> ${OUTDIR}/metabat2.log
rm -rf map.bam
######## END Metabat2


######## START Checkm
checkm lineage_wf -t $CPU_M -x fa ${OUTDIR}/bins checkm
checkm qa -t $CPU_M checkm/lineage.ms checkm -o 2 -f ${OUTDIR}/checkm_qa.txt
rm -rf checkm
######## END Checkm


######## START MIMAG
python3 checkm_mimag.py \
    ${OUTDIR}/bins \
    ${OUTDIR}/checkm_qa.txt \
    ${OUTDIR}/mimag_prok
######## END MIMAG
