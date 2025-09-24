# Ensure the set-hugepages service is started and enabled on boot
start_set_hugepages:
  service.running:
    - name: set-hugepages
    - enable: True
