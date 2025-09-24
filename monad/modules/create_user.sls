{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

create_user:
  user.present:
    - name: {{ user_name }}
    - createhome: True
    - home: {{ home_folder_path }}/{{ user_name }}
    - shell: /bin/bash
