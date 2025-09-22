{% set monad_grain = salt['grains.get']('monad', 'default') %}
{% set monad_version = salt['pillar.get']('monad_config:' ~ monad_grain ~ ':version', 'latest') %}

# apt update
refresh_apt_cache:
  module.run:
    - name: pkg.refresh_db

# apt install monad=VERSION (or latest)
install_monad:
  pkg.installed:
    - name: monad
    {% if monad_version and monad_version|lower != 'latest' %}
    - version: {{ monad_version }}
    {% endif %}

# apt-mark hold monad (idempotent)
hold_monad:
  cmd.run:
    - name: apt-mark hold monad
    - unless: apt-mark showhold | grep -qx monad
