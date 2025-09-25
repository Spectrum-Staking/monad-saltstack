{% set user_name        = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group            = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set home             = home_folder_path ~ '/' ~ user_name %}

fetch_forkpoint_script:
  cmd.run:
    - name: curl -sSL -o {{ home }}/scripts/download-forkpoint.sh https://bucket.monadinfra.com/scripts/testnet-2/download-forkpoint.sh
    - user: {{ user_name }}
    - cwd: {{ home }}
    - shell: /bin/bash

patch_forkpoint_script:
  file.replace:
    - name: {{ home }}/scripts/download-forkpoint.sh
    - pattern: '/home/'
    - repl: '{{ home_folder_path }}/'
    - backup: '.bak'

download_restore_script:
  cmd.run:
    - name: curl -sSL -o {{ home }}/scripts/restore_from_snapshot_systemd.sh https://pub-b0d0d7272c994851b4c8af22a766f571.r2.dev/scripts/testnet-2/restore_from_snapshot_systemd.sh -o restore_from_snapshot_systemd.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

patch_restore_script:
  file.replace:
    - name: {{ home }}/scripts/restore_from_snapshot_systemd.sh
    - pattern: '/home/'
    - repl: '{{ home_folder_path }}/'
    - backup: '.bak'