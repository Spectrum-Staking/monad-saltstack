# monad/modules/fetch_forkpoint.sls

{% set user_name        = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group            = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set home             = home_folder_path ~ '/' ~ user_name %}

# 1) Download the forkpoint script
fetch_forkpoint_script:
  cmd.run:
    - name: curl -sSL -o {{ home }}/download-forkpoint.sh https://bucket.monadinfra.com/scripts/testnet-2/download-forkpoint.sh
    - user: {{ user_name }}
    - cwd: {{ home }}
    - shell: /bin/bash
    - creates: {{ home }}/download-forkpoint.sh

# 2) Patch the script to replace any hardcoded "/home/" paths
patch_forkpoint_script:
  file.replace:
    - name: {{ home }}/download-forkpoint.sh
    - pattern: '/home/'
    - repl: '{{ home_folder_path }}/'
    - backup: '.bak'

# 3) Ensure it is executable and run it
run_forkpoint_script:
  cmd.run:
    - name: bash {{ home }}/download-forkpoint.sh
    - cwd: {{ home }}
    - user: {{ user_name }}
    - shell: /bin/bash
    - creates: {{ home }}/monad-bft/config/forkpoint/forkpoint.toml
