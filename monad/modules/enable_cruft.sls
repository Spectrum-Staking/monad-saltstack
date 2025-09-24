enable_monad_cruft_service:
  service.enabled:
    - name: monad-cruft.service

# Start + enable monad-cruft timer (this should stay running)
start_monad_cruft_timer:
  service.running:
    - name: monad-cruft.timer
    - enable: true