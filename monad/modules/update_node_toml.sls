{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home = home_folder_path ~ '/' ~ user_name %}

{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}
{% set node_name = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':node_name') %}
{% set beneficiary = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':beneficiary') %}

# Deploy node.toml configuration from template
deploy_node_toml:
  file.managed:
    - name: {{ home }}/monad-bft/config/node.toml
    - source: salt://monad/configs/{{ network }}/node.toml
    - template: jinja
    - context:
        network_name: {{ network }}
        beneficiary: "{{ beneficiary }}"
        node_name: {{ node_name }}
        address_with_port: __slot__:salt:cmd.shell('if [ -f {{ home }}/self-name-record.txt ]; then grep "^self_address" {{ home }}/self-name-record.txt | cut -d"\"" -f2; else echo "PLACEHOLDER_ADDRESS"; fi', runas="{{ user_name }}", shell="/bin/bash").strip()
        record_sig: __slot__:salt:cmd.shell('if [ -f {{ home }}/self-name-record.txt ]; then grep "^self_name_record_sig" {{ home }}/self-name-record.txt | cut -d"\"" -f2; else echo "PLACEHOLDER_SIG"; fi', runas="{{ user_name }}", shell="/bin/bash").strip()
    - user: {{ user_name }}
    - group: {{ group }}
    - mode: 644
    - makedirs: True
    - backup: minion

# Verify the deployed configuration
verify_node_toml_deployment:
  cmd.run:
    - name: |
        echo "Node.toml deployment summary:"
        echo "=============================="
        echo "Node name: $(grep '^node_name' {{ home }}/monad-bft/config/node.toml)"
        echo "Self address: $(grep '^self_address' {{ home }}/monad-bft/config/node.toml)"
        echo "Record signature: $(grep '^self_name_record_sig' {{ home }}/monad-bft/config/node.toml)"
    - runas: {{ user_name }}
    - shell: /bin/bash
    - require:
      - file: deploy_node_toml
