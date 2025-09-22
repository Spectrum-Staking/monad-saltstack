# Handle monad-cruft service (oneshot - runs once and stops)
start_monad_cruft_service:
  cmd.run:
    - name: systemctl start monad-cruft.service || echo "monad-cruft already completed"
    - shell: /bin/bash

enable_monad_cruft_service:
  service.enabled:
    - name: monad-cruft.service

# Start + enable monad-cruft timer (this should stay running)
start_monad_cruft_timer:
  service.running:
    - name: monad-cruft.timer
    - enable: true

# Start + enable core services (these should stay running)
start_monad_bft:
  service.running:
    - name: monad-bft.service
    - enable: true

start_monad_execution:
  service.running:
    - name: monad-execution.service
    - enable: true

start_monad_rpc:
  service.running:
    - name: monad-rpc.service
    - enable: true

# Show status for each service (separate steps)
status_monad_cruft:
  cmd.run:
    - name: systemctl --no-pager --full status monad-cruft.service
    - success_retcodes: [0, 3]  # Accept both active and inactive states
    - require:
      - cmd: start_monad_cruft_service

status_monad_bft:
  cmd.run:
    - name: systemctl --no-pager --full status monad-bft.service
    - require:
      - service: start_monad_bft

status_monad_execution:
  cmd.run:
    - name: systemctl --no-pager --full status monad-execution.service
    - require:
      - service: start_monad_execution

status_monad_rpc:
  cmd.run:
    - name: systemctl --no-pager --full status monad-rpc.service
    - require:
      - service: start_monad_rpc

# Grab recent logs for each (non-blocking; separate steps)
logs_monad_cruft:
  cmd.run:
    - name: journalctl -u monad-cruft -n 200 --since "1 hour ago" --no-pager
    - success_retcodes: [0, 1]  # Accept if no logs found
    - require:
      - cmd: start_monad_cruft_service

logs_monad_bft:
  cmd.run:
    - name: journalctl -u monad-bft -n 200 --since "1 hour ago" --no-pager
    - success_retcodes: [0, 1]  # Accept if no logs found
    - require:
      - service: start_monad_bft

logs_monad_execution:
  cmd.run:
    - name: journalctl -u monad-execution -n 200 --since "1 hour ago" --no-pager
    - success_retcodes: [0, 1]  # Accept if no logs found
    - require:
      - service: start_monad_execution

logs_monad_rpc:
  cmd.run:
    - name: journalctl -u monad-rpc -n 200 --since "1 hour ago" --no-pager
    - success_retcodes: [0, 1]  # Accept if no logs found
    - require:
      - service: start_monad_rpc
