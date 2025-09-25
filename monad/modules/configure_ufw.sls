allow_ssh:
  cmd.run:
    - name: ufw allow ssh
    - require:
      - cmd: set_default_allow_outgoing
    - unless: ufw status | grep -q "22/tcp.*ALLOW"

# Allow P2P port 8000
allow_p2p_port:
  cmd.run:
    - name: ufw allow 8000
    - require:
      - cmd: allow_ssh
    - unless: ufw status | grep -q "8000.*ALLOW"

# Allow MF Monitoring server to scrape chain metrics
allow_monitoring_server:
  cmd.run:
    - name: ufw allow from 84.32.32.227 proto tcp to any port 8889
    - require:
      - cmd: allow_p2p_port
    - unless: ufw status | grep -q "84.32.32.227.*8889/tcp.*ALLOW"

# Enable UFW
enable_ufw:
  cmd.run:
    - name: ufw --force enable

# Display final UFW status for verification
show_ufw_status:
  cmd.run:
    - name: |
        echo "=== UFW Configuration Complete ==="
        ufw status verbose
