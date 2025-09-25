{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

run_restore_script:
  cmd.run:
    - name: bash -c '{{ home_folder_path }}/{{ user_name }}/scripts/restore_from_snapshot.sh'

fix_permissions:
  file.directory:
    - name: /srv/monad/
    - user: monad
    - group: monad
    - recurse:
      - user
      - group