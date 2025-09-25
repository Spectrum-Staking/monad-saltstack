{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set config_dir = home_folder_path + '/' + user_name  %}

# Download validators.toml from remote URL to config directory
download_validators_toml:
  cmd.run:
    - name: curl -o {{ config_dir }}/monad-bft/config/validators.toml https://bucket.monadinfra.com/validators/testnet-2/validators.toml
    - runas: {{ user_name }}
    - cwd: {{ config_dir }}
    
