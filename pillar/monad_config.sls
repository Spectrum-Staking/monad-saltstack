monad_config:
  nodes:
    testnet1:
      node_name: TESTNODE
      network: testnet-2
      mpt_drive: nvme1n1
  networks:
    testnet-2:
      version: 0.11.1
      env_network_name: monad_testnet2
      beneficiary: 0x0000000000000000000000000000000000000000
  user_data:
    user_name: 'monad'
    group: 'monad'
    home_folder_path: "/srv"
    password: str0ngp@ssw0rd