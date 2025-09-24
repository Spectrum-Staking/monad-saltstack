{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

# Start monad-mpt service (oneshot - runs once and exits, don't treat as failure)
start_monad_mpt:
  cmd.run:
    - name: systemctl start monad-mpt || true
    - unless: journalctl -u monad-mpt --no-pager -q --since="1 hour ago" | grep -q "Finished monad-mpt.service"

# Always save the journal logs for debugging
save_journal_monad_mpt_log:
  cmd.run:
    - name: journalctl -u monad-mpt | sudo -u {{ user_name }} tee {{ home_folder_path }}/{{ user_name }}/journal_monad_mpt.log > /dev/null
    - shell: /bin/bash
    - user: root
