# Micro-C Snakemake workflow

## Configuration

The files containing the sequencing reads should be added under `reads` in the [config file](config/config.yaml).
The keys should be the name of the sample, and the value should be the corresponding read files using a glob wildcard that finds both files.
For example:

```yaml
reads:
    sample1: /data/dir/sample1_R*.fastq.gz
    sample2: /data/dir/sample2_R*.fastq.gz
```

The other thing that is needed is a genome to map the reads against, in fasta format.

```
genome: /data/dir/genome.fa.gz 
```

## Cluster configuration

The workflow works best by running it in a cluster environment, and in order to minimise the amount of typing needed on the command line, some configuration is needed.
One of the more convenient ways of handling this is with a [Snakemake profile](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles).
There are [existing templates](https://github.com/snakemake-profiles/doc) for the most common job schedulers available.
For convenience, a rule in the workflow is dedicated for setting up a profile, and it is handled by the following section in `config.yaml`:

```yaml
# Cluster configuration
cluster:
    # Cookiecutter parameters
    cookiecutter:
        url: https://github.com/Snakemake-Profiles/slurm
        profile_name: conifer-microc
        cluster_config: cluster/slurm.yaml
        advanced_argument_conversion: false

    # Default Snakemake parameters
    snakemake:
        use-conda: true
        use-envmodules: true
        restart-times: 0
        jobs: 3000
        latency-wait: 120
```

This particular example sets up a profile for running jobs using Slurm.
The section `cookiecutter` defines the parameters that are specific for the cookiecutter template that is being used---in this case https://github.com/Snakemake-Profiles/slurm.
In the section `snakemake` some defaults for Snakemake are set up.
These parameters should be named as the long options for Snakemake.
In order to set up a profile, run

```sh
snakemake --use-conda cluster_config
```

