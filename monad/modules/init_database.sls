{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

start_monad_mpt:
  module.run:
    - service.start:
      - name: monad-mpt

# Always save the journal logs for debugging
save_journal_monad_mpt_log:
  cmd.run:
    - name: journalctl -u monad-mpt | sudo -u {{ user_name }} tee {{ home_folder_path }}/{{ user_name }}/journal_monad_mpt.log > /dev/null
    - shell: /bin/bash
    - user: root
