import glob

def get_genome():
    if config['genome'].endswith('.gz'):
        return config['genome']
    else:
        return 'results/input/genome.fasta.gz'

def get_reads():
    filenames = []
    for k, v in config['reads'].items():
        filenames += glob.glob(v)
    return filenames
