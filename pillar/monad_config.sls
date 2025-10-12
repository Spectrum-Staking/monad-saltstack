monad_config:
  nodes:
    testnet1:
      node_name: TESTNODE
      network: testnet-2
      mpt_drive: nvme1n1
      password: str0ngp@ssw0rd
      beneficiary: "0x0000000000000000000000000000000000000001"
  networks:
    testnet-2:
      version: 0.11.3-tn2
      env_network_name: "monad_testnet2"
      validators_url: https://bucket.monadinfra.com/validators/testnet-2/validators.toml
  user_data:
    user_name: 'monad'
    group: 'monad'
    home_folder_path: "/srv"
