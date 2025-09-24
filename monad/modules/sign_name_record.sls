{% set user = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set home = salt['pillar.get']('monad_config:user_data:home_folder_path') ~ '/' ~ user %}
{% set shell = salt['pillar.get']('monad_config:user_data:shell', '/bin/bash') %}

# Run monad-sign-name-record and SAVE the output lines for later
run_sign_name_record:
  cmd.run:
    - name: |
        bash -lc '
          set -e
          source {{ home }}/.env
          /usr/local/bin/monad-sign-name-record \
            --address "$(curl -s4 ifconfig.me):8000" \
            --keystore-path {{ home }}/monad-bft/config/id-secp \
            --password "${KEYSTORE_PASSWORD}" \
            --self-record-seq-num 0 \
          | tee {{ home }}/self-name-record.txt
        '
    - cwd: {{ home }}
    - runas: {{ user }}
    - shell: {{ shell }}
    - creates: {{ home }}/self-name-record.txt
