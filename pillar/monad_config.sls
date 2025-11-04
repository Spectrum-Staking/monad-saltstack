monad_config:
  nodes:
    testnet1:
      node_name: TESTNODE
      network: testnet-1
      mpt_drive: nvme1n1
      password: str0ngp@ssw0rd
      beneficiary: "0x0000000000000000000000000000000000000001"
  networks:
    testnet-1:
      version: 0.11.3-tn1
      env_network_name: "monad_testnet2"
      validators_url: https://bucket.monadinfra.com/validators/testnet/validators.toml
      forkpoint_url: https://bucket.monadinfra.com/scripts/testnet/download-forkpoint.sh
      restore_from_snapshot_cl_url: https://pub-b0d0d7272c994851b4c8af22a766f571.r2.dev/scripts/testnet/restore_from_snapshot_systemd.sh
      restore_from_snapshot_mf_url: https://bucket.monadinfra.com/scripts/testnet/restore-from-snapshot.sh  user_data:
    user_name: 'monad'
    group: 'monad'
    home_folder_path: "/srv"
