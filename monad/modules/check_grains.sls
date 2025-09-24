# Read the monad grain as a string (default to empty string)
{% set monad_grain = salt['grains.get']('monad', '') %}
{% set node_type = monad_grain|string %}

# Pull valid node types from pillar (support both ...valid_node_types and ...valid_node_type)
{% set _vt_default = ['testnet', 'mainnet'] %}
{% set _vt_from_plural = salt['pillar.get']('monad_config:valid_node_types', None) %}
{% set _vt_from_singular = salt['pillar.get']('monad_config:valid_node_type', None) %}
{% set _vt_raw = _vt_from_plural if _vt_from_plural is not none else (_vt_from_singular if _vt_from_singular is not none else _vt_default) %}
{% set valid_node_types = _vt_raw if (_vt_raw is sequence and _vt_raw is not string) else [_vt_raw] %}

check_monad_grain:
  test.configurable_test_state:
    - name: Check if 'monad' grain is present
    - result: {{ True if node_type else False }}
    - comment: |
        {%- if node_type %}
        Monad grain is present on minion: {{ node_type }}
        {%- else %}
        ERROR: Monad grain is missing! Please ensure the grain is configured on the Salt minion (e.g., monad: testnet|mainnet).
        {%- endif %}
    - failhard: True

validate_grain_in_valid_node_types:
  test.configurable_test_state:
    - name: Validate if grain value '{{ node_type }}' is in the valid node types
    - result: {{ True if node_type in valid_node_types else False }}
    - comment: |
        {%- if node_type in valid_node_types %}
        Grain value '{{ node_type }}' is valid. It matches one of: {{ valid_node_types | join(', ') }}.
        {%- else %}
        ERROR: Grain value '{{ node_type }}' is not valid! Must be one of: {{ valid_node_types | join(', ') }}.
        {%- endif %}
    - failhard: True

