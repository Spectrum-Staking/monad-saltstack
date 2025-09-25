{% set user_name        = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group            = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set home             = home_folder_path ~ '/' ~ user_name %}

run_download_forkpoint:
  cmd.run:
    - name: |
        bash -c '
        source .env && \
        bash scripts/download-forkpoint.sh
        '
    - runas: {{ user_name }}
    - shell: /bin/bash
    - cwd: {{ home_folder_path }}/{{ user_name }}

