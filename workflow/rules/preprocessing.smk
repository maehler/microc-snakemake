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
    output: 'results/input/reads.fq.gz'
    shell: 'cat {input} > {output}'

rule compress_fasta:
    input: config['genome']
    output: 'results/input/genome.fasta.gz'
    envmodules: 'bioinfo-tools', 'samtools/1.14'
    shell: 'bgzip -c {input} > {output}'
