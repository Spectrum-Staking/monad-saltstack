{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}


# Run reset-workspace.sh with /opt/ replaced by {{ home_folder_path }}
reset_workspace:
  cmd.run:
    - name: bash /opt/monad/scripts/reset-workspace.sh
    - runas: {{ user_name }}
    - shell: /bin/bash
    - cwd: {{ home_folder_path }}/{{ user_name }}
