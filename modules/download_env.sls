{% set user_name = salt['pillar.get']('monad_config:user_data:user_name') %}
{% set group = salt['pillar.get']('monad_config:user_data:group') %}
{% set home_folder_path = salt['pillar.get']('monad_config:user_data:home_folder_path') %}
{% set password = salt['pillar.get']('monad_config:user_data:password') %}

# Download .env.example file to user's home directory
download_env_file:
  cmd.run:
    - name: curl -o {{home_folder_path}}/{{user_name}}/.env https://pub-b0d0d7272c994851b4c8af22a766f571.r2.dev/config/testnet-2/latest/.env.example
    - user: {{user_name}}
    - unless: test -f {{home_folder_path}}/{{user_name}}/.env

# Set proper ownership of the downloaded file
set_env_file_ownership:
  file.managed:
    - name: {{home_folder_path}}/{{user_name}}/.env
    - user: {{user_name}}
    - group: {{group}}
    - mode: 644

# Replace /home/monad with the configured home folder path
update_config_dir_path:
  file.replace:
    - name: {{home_folder_path}}/{{user_name}}/.env
    - pattern: 'CONFIG_DIR=/home/monad'
    - repl: 'CONFIG_DIR={{home_folder_path}}/{{user_name}}'

# Set the keystore password
update_keystore_password:
  file.replace:
    - name: {{home_folder_path}}/{{user_name}}/.env
    - pattern: 'KEYSTORE_PASSWORD='
    - repl: 'KEYSTORE_PASSWORD={{password}}'
