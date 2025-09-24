run_restore_script:
  cmd.run:
    - name: bash scripts/restore_from_snapshot_systemd.sh
    - runas: {{ user_name }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash