# monad/modules/add_gpg_key.sls

gpg_key_prereqs:
  pkg.installed:
    - pkgs:
      - curl
      - gnupg
      - ca-certificates

apt_keyrings_dir:
  file.directory:
    - name: /etc/apt/keyrings
    - mode: "0755"
    - user: root
    - group: root

category_labs_keyring:
  cmd.run:
    - name: >
        bash -lc 'curl -fsSL https://pkg.category.xyz/keys/public-key.asc
        | gpg --dearmor -o /etc/apt/keyrings/category-labs.gpg'
    - creates: /etc/apt/keyrings/category-labs.gpg
