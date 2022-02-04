#!/usr/bin/env python3

from cookiecutter.main import cookiecutter
from pathlib import Path
import yaml

def profile_init(url, params):
    profile_path = cookiecutter(
        template=url, no_input=True,
        extra_context=params, overwrite_if_exists=True,
        output_dir=Path(Path.home(), '.config/snakemake'))

    return profile_path

def update_snakemake_params(profile_path, sm_config):
    config_fname = Path(profile_path, 'config.yaml')
    with open(config_fname) as f:
        conf = yaml.safe_load(f)

    for key, value in sm_config.items():
        conf[key] = value

    with open(config_fname, 'w') as f:
        yaml.dump(data=conf, stream=f)

def get_params(sm_config):
    params = {
        'url': '',
        'cookiecutter': {},
        'snakemake': {}
    }

    if 'url' not in sm_config['cookiecutter']:
        raise KeyError('no cookiecutter URL given')

    params['url'] = sm_config['cookiecutter']['url']

    for key, value in sm_config['cookiecutter'].items():
        if key == 'url':
            continue
        # TODO: try to make a more general solution for paths
        if key == 'cluster_config':
            value = Path(value).resolve()
        params['cookiecutter'][key] = value

    params['snakemake'] = sm_config['snakemake']

    return params

def main():
    params = get_params(snakemake.config['cluster'])

    profile_path = profile_init(
        params['url'], params['cookiecutter'])

    update_snakemake_params(
        profile_path, params['snakemake'])

    print('Profile saved at {profile_path}, run snakemake '
          'with --profile {profile_name} to use it' \
              .format(profile_path=profile_path,
                      profile_name=params['cookiecutter']['profile_name']))

if __name__ == '__main__':
    main()
