
{% set monad_node = salt['grains.get']('monad', {}) %}
{% set drive = salt['pillar.get']('monad_config:nodes').get(monad_node).get('mpt_drive') %}

# Install tool
install_nvme_cli:
  pkg.installed:
    - name: nvme-cli

# Validate the target drive is clean (no partitions, no mounts, no FS sigs)
validate_disk_clean:
  cmd.run:
    - name: |
        # Check for existing partitions
        if lsblk -n -o NAME /dev/{{ drive }} | grep -qE '^{{ drive }}p[0-9]+'; then
          echo "ERROR: /dev/{{ drive }} has existing partitions."
          exit 1
        fi

        # Check for mounted partitions
        if mount | grep -q "/dev/{{ drive }}"; then
          echo "ERROR: /dev/{{ drive }} is mounted."
          exit 1
        fi

        # Check for filesystem signatures
        if wipefs -n /dev/{{ drive }} | grep -q '^'; then
          echo "WARNING: /dev/{{ drive }} has filesystem signatures. Clean with wipefs."
          exit 1
        fi

        echo "Disk /dev/{{ drive }} appears clean. Continuing."
    - require:
      - pkg: install_nvme_cli

# Create GPT and a single "triedb" partition, then let the kernel catch up
partition_drive:
  cmd.run:
    - name: |
        set -e
        parted --script /dev/{{ drive }} mklabel gpt
        parted --script /dev/{{ drive }} mkpart triedb 0% 100%
        # make kernel re-read and wait for udev
        partprobe /dev/{{ drive }} || true
        udevadm settle
    - unless: parted /dev/{{ drive }} print | grep -q "triedb"
    - require:
      - cmd: validate_disk_clean

# Write udev rule using the *current* PARTUUID of the triedb partition (MOP-aligned)
# We *always* rewrite it to avoid stale PARTUUID after repartitioning.
udev_rule_triedb:
  cmd.run:
    - name: |
        set -e
        PARTUUID="$(lsblk -no PARTUUID /dev/{{ drive }}p1)"
        if [ -z "$PARTUUID" ]; then
          echo "Could not read PARTUUID for /dev/{{ drive }}p1" >&2
          exit 1
        fi
        # MOP-aligned: match PARTUUID, create /dev/triedb, MODE=0666
        printf 'ENV{ID_PART_ENTRY_UUID}=="%s", MODE="0666", SYMLINK+="triedb"\n' "$PARTUUID" > /etc/udev/rules.d/99-triedb.rules
    - require:
      - cmd: partition_drive

# Reload rules, trigger just this disk, and settle
reload_udev_rules:
  cmd.run:
    - name: |
        set -e
        udevadm control --reload-rules
        if [ -e /dev/{{ drive }}p1 ]; then
          udevadm trigger --name-match=/dev/{{ drive }}p1
        else
          udevadm trigger
        fi
        udevadm settle
    - require:
      - cmd: udev_rule_triedb

# Wait for /dev/triedb to exist before chmod (handles propagation/races)
wait_for_triedb:
  cmd.run:
    - name: |
        for i in $(seq 1 30); do
          if [ -e /dev/triedb ]; then
            exit 0
          fi
          sleep 0.2
        done
        echo "/dev/triedb did not appear in time." >&2
        exit 1
    - require:
      - cmd: reload_udev_rules

# Set permissions *matching the MOP* (rw for all; no execute)
set_triedb_permissions:
  cmd.run:
    - name: chmod 666 /dev/triedb
    - require:
      - cmd: wait_for_triedb

# Check LBA Format (512 bytes should be 'in use'); proceed to format if needed
check_lba_format:
  cmd.run:
    - name: nvme id-ns -H /dev/{{ drive }} | grep 'LBA Format' | grep 'in use'
    - require:
      - pkg: install_nvme_cli
      - cmd: set_triedb_permissions

# If not 512-byte LBA, format to lbaf=0
format_lba_if_needed:
  cmd.run:
    - name: nvme format --lbaf=0 /dev/{{ drive }}
    - unless: nvme id-ns -H /dev/{{ drive }} | grep 'LBA Format' | grep 'in use' | grep -q '512 bytes'
    - require:
      - cmd: check_lba_format

# Verify LBA format after potential reformat
verify_lba_format:
  cmd.run:
    - name: |
        echo "=== Final LBA Format Verification ==="
        nvme id-ns -H /dev/{{ drive }} | grep 'LBA Format' | grep 'in use'
        echo "Expected: LBA Format 0 : Metadata Size: 0 bytes - Data Size: 512 bytes - Relative Performance: 0 Best (in use)"
    - require:
      - cmd: format_lba_if_needed

# Final status dump
final_status_check:
  cmd.run:
    - name: |
        echo "=== TrieDB Drive Setup Complete ==="
        echo "Drive: /dev/{{ drive }}"
        echo "Partition Information:"
        parted /dev/{{ drive }} print
        echo ""
        echo "TrieDB Device:"
        ls -la /dev/triedb
        echo ""
        echo "udev Rule:"
        cat /etc/udev/rules.d/99-triedb.rules
    - require:
      - cmd: verify_lba_format
