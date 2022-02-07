rule pairtools_parse:
    input:
        bam='results/alignments/alignments.bam',
        genome='results/input/genome.genome'
    output: 'results/alignments/alignments_q{min_mapq}_sorted.pairsam.gz'
    conda: '../envs/pairtools.yaml'
    params:
        min_mapq=lambda w: w['min_mapq'],
        tmp_dir=lambda w: '${SNIC_TMP}'
    threads: 10
    shell: """
    pairtools parse \\
        --nproc-in {threads} \\
        --nproc-out {threads} \\
        --min-mapq {params.min_mapq} \\
        --walks-policy 5unique \\
        --max-inter-align-gap 30 \\
        --chroms-path {input.genome} \\
        {input.bam} | \\
        pairtools sort \\
            --tmpdir {params.tmp_dir} \\
            --nproc {threads} \\
            --nproc-in {threads} \\
            --nproc-out {threads} \\
            --output {output}
    """

rule pairtools_dedup:
    input: 'results/alignments/alignments_q{min_mapq}_sorted.pairsam.gz'
    output:
        dedup='results/alignments/alignments_q{min_mapq}_deduped.pairsam.gz',
        stats='results/alignments/alignments_q{min_mapq}_stats.txt'
    conda: '../envs/pairtools.yaml'
    threads: 10
    shell: """
    pairtools dedup \\
        --nproc-in {threads} \\
        --nproc-out {threads} \\
        --mark-dups \\
        --output-stats {output.stats} \\
        --output {output.dedup} \\
        {input}
    """

rule plot_pairtools_stats:
    input: 'results/alignments/alignments_q{min_mapq}_stats.txt'
    output: 'results/alignments/pairtools_q{min_mapq}_stats.png'
    conda: '../envs/tidyverse.yaml'
    envmodules: 'R/4.1.1', 'R_packages/4.1.1'
    script: '../scripts/plot_pairtools_stats.R'
