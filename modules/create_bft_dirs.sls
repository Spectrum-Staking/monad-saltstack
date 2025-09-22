{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}

# Create monad-bft directory
create_monad_bft_base_dir:
  file.directory:
    - name: {{ home_folder_path }}/{{ user_name }}/monad-bft
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

# Create monad-bft directory
create_monad_bft_config_dir:
  file.directory:
    - name: {{ home_folder_path }}/{{ user_name }}/monad-bft/config
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

# Create monad-bft/ledger directory
create_monad_bft_ledger_dir:
  file.directory:
    - name: {{ home_folder_path }}/{{ user_name }}/monad-bft/ledger
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

# Create monad-bft/config/forkpoint directory
create_monad_bft_forkpoint_dir:
  file.directory:
    - name: {{ home_folder_path }}/{{ user_name }}/monad-bft/config/forkpoint
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

# Create and chown the opt monad backup directory
create_monad_backup_dir:
  file.directory:
    - name: /opt/monad/backup
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True
