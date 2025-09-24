{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

# Stop relevant monad services
stop_monad_services:
  service.dead:
    - names:
      - monad-bft
      - monad-execution
      - monad-rpc

# Download download-forkpoint.sh script
download_forkpoint_script:
  cmd.run:
    - name: curl -sSL https://bucket.monadinfra.com/scripts/testnet-2/download-forkpoint.sh -o download-forkpoint.sh
    - user: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Replace /home with {{ home_folder_path }} inside the script
patch_forkpoint_script:
  cmd.run:
    - name: sed -i "s|/home|{{ home_folder_path }}|g" download-forkpoint.sh
    - user: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Execute the patched script
run_forkpoint_script:
  cmd.run:
    - name: bash download-forkpoint.sh
    - user: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Start monad services
start_monad_services:
  service.running:
    - names:
      - monad-bft
      - monad-execution
      - monad-rpc
    - enable: True

# Append systemctl service statuses to journal_monad_mpt.log
append_services_status_to_log:
  cmd.run:
    - name: systemctl list-units --type=service otelcol.service monad-bft.service monad-execution.service monad-rpc.service >> {{ home_folder_path }}/{{ user_name }}/journal_monad_mpt.log
    - user: {{ user_name }}
    - shell: /bin/bash


# Append journal output of monad-bft to a log file
append_journal_monad_bft:
  cmd.run:
    - name: journalctl -u monad-bft | sudo -u {{ user_name }} tee -a {{ home_folder_path }}/{{ user_name }}/journal_monad_bft.log > /dev/null
    - shell: /bin/bash
    - user: root
