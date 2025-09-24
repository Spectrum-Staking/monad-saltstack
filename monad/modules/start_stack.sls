start_monad_bft:
  service.running:
    - names: 
      - monad-bft
      - monad-execution
      - monad-rpc
    - enable: true

status_monad_bft:
  cmd.run:
    - name: systemctl --no-pager --full status monad-bft.service

status_monad_execution:
  cmd.run:
    - name: systemctl --no-pager --full status monad-execution.service

status_monad_rpc:
  cmd.run:
    - name: systemctl --no-pager --full status monad-rpc.service
