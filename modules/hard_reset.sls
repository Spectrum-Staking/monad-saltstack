{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

# Install aria2 package
install_aria2:
  pkg.installed:
    - name: aria2

# Run reset-workspace.sh with /opt/ replaced by {{ home_folder_path }}
reset_workspace:
  cmd.run:
    - name: >
        sed "s|/opt/|{{ home_folder_path }}/|" /opt/monad/scripts/reset-workspace.sh | bash
    - runas: {{ user_name }}
    - shell: /bin/bash
    - cwd: {{ home_folder_path }}/{{ user_name }}

# Download the restore_from_snapshot_systemd.sh
download_restore_script:
  cmd.run:
    - name: curl -sSL https://pub-b0d0d7272c994851b4c8af22a766f571.r2.dev/scripts/testnet-2/restore_from_snapshot_systemd.sh -o restore_from_snapshot_systemd.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash
    - unless: test -f {{ home_folder_path }}/{{ user_name }}/restore_from_snapshot_systemd.sh

# Patch the script (replace /home/ with correct path, keeping the trailing slash)
patch_restore_script:
  cmd.run:
    - name: sed -i "s|/home/|{{ home_folder_path }}/|g" restore_from_snapshot_systemd.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Run the restore_from_snapshot_systemd.sh script
run_restore_script:
  cmd.run:
    - name: bash restore_from_snapshot_systemd.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Download forkpoint.sh script
download_forkpoint_script:
  cmd.run:
    - name: curl -sSL https://bucket.monadinfra.com/scripts/testnet-2/download-forkpoint.sh -o download-forkpoint.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash
    - unless: test -f {{ home_folder_path }}/{{ user_name }}/download-forkpoint.sh

# Patch the download-forkpoint.sh script
update_forkpoint_script:
  cmd.run:
    - name: sed -i "s|/home/|{{ home_folder_path }}/|g" download-forkpoint.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash

# Run download-forkpoint.sh script
run_download_forkpoint:
  cmd.run:
    - name: |
        bash -c '
        source {{ home_folder_path }}/{{ user_name }}/.env && \
        bash download-forkpoint.sh
        '
    - runas: {{ user_name }}
    - shell: /bin/bash
    - cwd: {{ home_folder_path }}/{{ user_name }}

# Start the oneshot monad-mpt service (run once and exit)
start_monad_mpt_service:
  cmd.run:
    - name: systemctl start monad-mpt
    - unless: systemctl is-active monad-mpt || systemctl show -p ActiveState monad-mpt | grep -q "ActiveState=inactive"

# Enable monad-mpt for future runs
enable_monad_mpt_service:
  service.enabled:
    - name: monad-mpt

# Start persistent monad services
start_persistent_monad_services:
  service.running:
    - names:
      - monad-bft
      - monad-execution  
      - monad-rpc
    - enable: True

# Collect systemd service statuses and save locally (on the minion)
collect_services_status:
  cmd.run:
    - name: systemctl list-units --type=service otelcol.service monad-bft-fullnode.service monad-bft.service monad-execution.service monad-rpc.service > /tmp/services_unit_status.log
    - runas: root

# Append journal output of monad-bft to a log file
append_journal_monad_bft:
  cmd.run:
    - name: journalctl -u monad-bft | sudo -u {{ user_name }} tee -a {{ home_folder_path }}/{{ user_name }}/journal_monad_bft.log > /dev/null
    - shell: /bin/bash
    - user: root
