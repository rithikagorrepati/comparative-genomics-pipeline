nextflow.enable.dsl=2

params.reads = "data/*_{R1,R2}_001.fastq.gz"
params.outdir = "results"
params.skesa_threads = 4
params.parsnp_threads = 4
params.reference = "!"

process FASTP {
    tag "${sample_id}"
    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1_trimmed.fq.gz"),
          path("${sample_id}_R2_trimmed.fq.gz")

    script:
    """
    fastp \
        -i ${reads[0]} \
        -I ${reads[1]} \
        -o ${sample_id}_R1_trimmed.fq.gz \
        -O ${sample_id}_R2_trimmed.fq.gz
    """
}

process SKESA {
    tag "${sample_id}"
    publishDir "${params.outdir}/skesa", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id), path("${sample_id}_contigs.fasta")

    script:
    """
    skesa \
        --fastq ${read1},${read2} \
        --cores ${params.skesa_threads} \
        --contigs_out ${sample_id}_contigs.fasta
    """
}

process PARSNP {
    tag "core-genome alignment"
    publishDir "${params.outdir}/parsnp", mode: 'copy'

    input:
    path assemblies

    output:
    path "parsnp_out"

    script:
    def assembly_files = assemblies.join(' ')
    def reference_arg = params.reference == "!" ? "-r !" : "-r ${params.reference}"

    """
    mkdir -p assemblies
    cp ${assembly_files} assemblies/

    parsnp \
        -d assemblies \
        ${reference_arg} \
        -o parsnp_out \
        -p ${params.parsnp_threads} \
        --use-fasttree \
        --fo
    """
}

workflow {
    reads_ch = Channel.fromFilePairs(
        params.reads,
        checkIfExists: true
    )

    fastp_out = FASTP(reads_ch)

    skesa_out = SKESA(fastp_out)

    assemblies_ch = skesa_out
        .map { sample_id, contigs -> contigs }
        .collect()

    PARSNP(assemblies_ch)
}
