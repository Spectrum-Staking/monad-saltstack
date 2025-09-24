monad_config:
  nodes:
    monad_testnet1:
      node_name: TESTNODE
      network: testnet
      mpt_drive: nvme1n1
  networks:
    testnet:
      version: 0.11.1
      env_network_name: monad_testnet2
      config_network_name: testnet-2
      beneficiary: 0x0000000000000000000000000000000000000000
  user_data:
    user_name: 'monad'
    group: 'monad'
    home_folder_path: "/srv"
    password: str0ngp@ssw0rd
  valid_node_type:
    - testnet
    - mainnet
