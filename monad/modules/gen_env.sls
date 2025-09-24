{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set password = salt['pillar.get']('monad_config:user_data:password') %}

{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:' ~ node ~ ':network') %}
{% set network_name = salt['pillar.get']('monad_config:networks' ~ network ~ ':name') %}

# Set proper ownership of the downloaded file
create_env_file:
  file.managed:
    - name: {{home_folder_path}}/{{user_name}}/.env
    - user: {{user_name}}
    - group: {{group}}
    - mode: 644
    - contents: |
    CONFIG_DIR={{home_folder_path}}/{{user_name}}
    KEYSTORE_PASSWORD={{ password }}
    CHAIN={{ chain_name }}