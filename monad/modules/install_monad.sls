{% set node = salt['grains.get']('monad', {}) %}
{% set network = salt['pillar.get']('monad_config:' ~ node ~ ':network') %}
{% set monad_version = salt['pillar.get']('monad_config:networks' ~ network ~ ':version') %}

install_monad:
  pkg.installed:
    - name: monad
    - version: {{ monad_version }}
    - refresh: true

hold_monad:
  cmd.run:
    - name: apt-mark hold monad
    - unless: apt-mark showhold | grep -qx monad
