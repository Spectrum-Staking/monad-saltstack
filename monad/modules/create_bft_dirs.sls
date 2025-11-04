{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

# Create monad-bft directory
create_monad_dirs:
  file.directory:
    - names:
      - {{ home_folder_path }}/{{ user_name }}/monad-bft/config
      - {{ home_folder_path }}/{{ user_name }}/monad-bft/ledger
      - {{ home_folder_path }}/{{ user_name }}/monad-bft/config/forkpoint
      - {{ home_folder_path }}/{{ user_name }}/monad-bft/config/validators
      - {{ home_folder_path }}/{{ user_name }}/backup
      - {{ home_folder_path }}/{{ user_name }}/scripts
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True