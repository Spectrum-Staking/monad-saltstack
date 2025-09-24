{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set shell = salt['pillar.get']('monad_config:user_data:shell') %}

# Create SECP key
create_secp_key:
  cmd.run:
    - name: |
        source {{ home_folder_path }}/{{ user_name }}/.env
        monad-keystore create \
        --key-type secp \
        --keystore-path {{ home_folder_path }}/{{ user_name }}/monad-bft/config/id-secp \
        --password "${KEYSTORE_PASSWORD}" > {{ home_folder_path }}/{{ user_name }}/backup/secp-backup
    - runas: {{ user_name }}
    - shell: {{ shell }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - unless: test -f {{ home_folder_path }}/{{ user_name }}/monad-bft/config/id-secp

# Create BLS key
create_bls_key:
  cmd.run:
    - name: |
        source {{ home_folder_path }}/{{ user_name }}/.env
        monad-keystore create \
        --key-type bls \
        --keystore-path {{ home_folder_path }}/{{ user_name }}/monad-bft/config/id-bls \
        --password "${KEYSTORE_PASSWORD}" > {{ home_folder_path }}/{{ user_name }}/backup/bls-backup
    - runas: {{ user_name }}
    - shell: {{ shell }}
    - cwd: {{ home_folder_path }}/{{ user_name }}
    - unless: test -f {{ home_folder_path }}/{{ user_name }}/monad-bft/config/id-bls

