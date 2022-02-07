localrules: genome_file, cat_reads

rule index_fasta:
    input: get_genome()
    output: '{}.fai'.format(get_genome())
    envmodules: 'bioinfo-tools', 'samtools/1.14'
    shell: 'samtools faidx {input}'

rule genome_file:
    input: '{}.fai'.format(get_genome())
    output: 'results/input/genome.genome'
    shell: 'cut -f1,2 {input} > {output}'

rule cat_reads:
    input: get_reads(),
    output:
        first='results/input/reads_1.fq.gz',
        second='results/input/reads_2.fq.gz'
    shell: """
    FIRST=$(find {input} | grep R1)
    SECOND=$(find {input} | grep R2)
    cat ${{FIRST}} > {output.first}
    cat ${{SECOND}} > {output.second}
    """

rule compress_fasta:
    input: config['genome']
    output: 'results/input/genome.fasta.gz'
    envmodules: 'bioinfo-tools', 'samtools/1.14'
    shell: 'bgzip -c {input} > {output}'
