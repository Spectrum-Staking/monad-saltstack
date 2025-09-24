{% set user_name = salt['pillar.get']('monad_config:user_data:user_name', 'monad') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path', '/srv') %}
{% set corrected_path = home_folder_path.rstrip('/') ~ '/' ~ user_name %}

# Fix all systemd service files with a single command
fix_systemd_monad_paths:
  cmd.run:
    - name: |
        for file in /usr/lib/systemd/system/monad-*.service; do
          if [ -f "$file" ]; then
            sed -i.bak 's|/home/{{ user_name }}|{{ corrected_path }}|g' "$file"
          fi
        done
    - onlyif: grep -l '/home/{{ user_name }}' /usr/lib/systemd/system/monad-*.service 2>/dev/null

# Fix all monad script files
fix_monad_script_paths:
  cmd.run:
    - name: |
        for file in /opt/monad/scripts/*.sh; do
          if [ -f "$file" ]; then
            sed -i.bak 's|/home/{{ user_name }}|{{ corrected_path }}|g' "$file"
          fi
        done
    - onlyif: test -d /opt/monad/scripts && grep -l '/home/{{ user_name }}' /opt/monad/scripts/*.sh 2>/dev/null

# Reload systemd after changes
systemd-daemon-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - cmd: fix_systemd_monad_paths
