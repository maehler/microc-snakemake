rule cluster_config:
    """
    Generate a cluster profile.
    """
    output: directory( \
        '{home}/.config/snakemake/{profile_name}' \
            .format(home=Path.home(), \
                    profile_name=config['cluster']['cookiecutter']['profile_name']))
    conda: '../envs/cluster_config.yaml'
    script: '../scripts/cluster_config.py'
