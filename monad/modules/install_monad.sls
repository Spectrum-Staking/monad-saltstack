{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:nodes:' ~ node ~ ':network') %}
{% set monad_version = salt['pillar.get']('monad_config:networks:' ~ network ~ ':version') %}

install_monad:
  pkg.installed:
    - name: monad
    - version: {{ monad_version }}
    - refresh: true
    - update_holds: true