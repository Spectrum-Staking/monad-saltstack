{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}

include:
  - monad.modules.stop_stack
  - monad.modules.reset_workspace
{% if network == 'testnet' %}
  - monad.modules.restore_from_snapshot
{% endif %}
  - monad.modules.download_forkpoint
  - monad.modules.download_validators
  - monad.modules.init_database
  - monad.modules.start_stack