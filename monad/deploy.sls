{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}

include:
  - monad.modules.install_deps
  - monad.modules.provision_triedb_disk
  - monad.modules.create_user
  - monad.modules.create_bft_dirs
  - monad.modules.add_apt_repo
  - monad.modules.add_gpg_key
  - monad.modules.install_monad
  - monad.modules.download_scripts
  - monad.modules.gen_env
  - monad.modules.key_mgmt
  - monad.modules.download_validators
  - monad.modules.sign_name_record
  - monad.modules.update_node_toml
  - monad.modules.fix_monad_paths
  - monad.modules.init_hugepages
  - monad.modules.init_database
  - monad.modules.download_forkpoint
  {% if network == 'testnet' %}
  - monad.modules.reset_workspace
  - monad.modules.restore_from_snapshot
  {% endif %}
  - monad.modules.start_stack
  - monad.modules.enable_cruft

