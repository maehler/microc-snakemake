rule bwa_index:
    input: get_genome()
    output: 'results/input/genome.bwt'
    envmodules: 'bioinfo-tools', 'bwa/0.7.17'
    shell: """
    ASM={output}
    PREFIX=${{ASM%.bwt}}
    bwa index -p ${{PREFIX}} {input}
    """

rule bwa:
    input:
        first_reads='results/input/reads_1.fq.gz',
        second_reads='results/input/reads_2.fq.gz',
        bwa_idx='results/input/genome.bwt'
    output:
        'results/alignments/alignments.bam'
    log: 'log/bwa.log'
    envmodules: 'bioinfo-tools', 'bwa/0.7.17', 'samtools/1.14'
    threads: 10
    params:
    shell: """
    ASM={input.bwa_idx}
    PREFIX=${{ASM%.bwt}}
    bwa mem -5SP -T0 \\
        -t{threads} \\
        ${{PREFIX}} \\
        {input.first_reads} \\
        {input.second_reads} | \\
        samtools view -b > {output}
    """
