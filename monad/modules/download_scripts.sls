{% set user_name        = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group            = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set home             = home_folder_path ~ '/' ~ user_name %}

{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}
{% set forkpoint_url = salt['pillar.get']('monad_config:networks:' ~ network ~ ':validators_url') %}
{% set restore_from_snapshot_cf_url = salt['pillar.get']('monad_config:networks:' ~ network ~ ':validators_url') %}


fetch_forkpoint_script:
  file.managed:
    - name: {{ home }}/scripts/download-forkpoint.sh
    - source: {{ forkpoint_url }}
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 766
    - skip_verify: true

patch_forkpoint_script:
  file.replace:
    - name: {{ home }}/scripts/download-forkpoint.sh
    - pattern: '/home/'
    - repl: '{{ home_folder_path }}/'
    - backup: '.bak'

download_cf_restore_script:
  file.managed:
    - name: {{ home }}/scripts/restore_from_snapshot_systemd.sh
    - source: {{ restore_from_snapshot_cf_url }}
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 766
    - skip_verify: true

patch_cf_restore_script:
  file.replace:
    - name: {{ home }}/scripts/restore_from_snapshot_systemd.sh
    - pattern: '/home/'
    - repl: '{{ home_folder_path }}/'
    - backup: '.bak'