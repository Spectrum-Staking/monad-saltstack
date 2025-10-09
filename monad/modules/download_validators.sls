{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set config_dir = home_folder_path + '/' + user_name  %}

# Download validators.toml from remote URL to config directory
download_validators_toml:
  file.managed:
    - name: {{ config_dir }}/monad-bft/config/validators/validators.toml
    - source: https://bucket.monadinfra.com/validators/testnet-2/validators.toml
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 766
    - skip_verify: true
    
