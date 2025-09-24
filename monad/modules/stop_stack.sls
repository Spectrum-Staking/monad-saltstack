stop_monad_stack:
  service.dead:
    - names: 
      - monad-bft
      - monad-execution
      - monad-rpc