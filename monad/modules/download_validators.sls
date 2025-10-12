{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set config_dir = home_folder_path + '/' + user_name  %}

{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}
{% set validators_url = salt['pillar.get']('monad_config:networks:' ~ network ~ ':validators_url') %}

# Download validators.toml from remote URL to config directory
download_validators:
  cmd.run:
    - name: wget -O {{ config_dir }}/monad-bft/config/validators/validators.toml {{ validators_url }}
    - runas: {{ user_name }}
    
