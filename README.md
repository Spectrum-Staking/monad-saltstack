# Monad SaltStack Formulas

This repository contains SaltStack formulas for deploying and managing Monad nodes.

## Prerequisites

Before applying these states, you need to 

1. Create a pillar file named `monad_config.sls` in your Salt master's pillar root directory (e.g., `/srv/salt/pillar/monad_config.sls`). This file contains the configuration for your Monad node.

2. Apply grain `monad:nodename` to the target machine. Example: `salt monad-test grains.set monad testnet-node-1`

Here is an example of the `monad_config.sls` file:

```yaml
monad_config:
  nodes:
    testnet-node-1:
      node_name: TESTNODE
      # The node is part of TN1
      network: testnet
      mpt_drive: <MPTDISK e.g. nvme0n1>
      password: <YOUR_KEYSTORE_PASSWORD>
      beneficiary: "0xYOUR_BENEFICIARY_ADDRESS"
  networks:
    # Per network parameters (TN1)
    testnet:
      version: 0.12.0~rc
      env_network_name: "monad_testnet"
      validators_url: https://bucket.monadinfra.com/validators/testnet/validators.toml
      forkpoint_url: https://bucket.monadinfra.com/scripts/testnet/download-forkpoint.sh
      restore_from_snapshot_cl_url: https://pub-b0d0d7272c994851b4c8af22a766f571.r2.dev/scripts/testnet/restore_from_snapshot_systemd.sh
      restore_from_snapshot_mf_url: https://bucket.monadinfra.com/scripts/testnet/restore-from-snapshot.sh  
  user_data:
    user_name: 'monad'
    group: 'monad'
    home_folder_path: "/srv"
```

### Pillar Data Explanation

*   `user_data`: Contains information about the user that will run the monad node.
    *   `user_name`, `group`, `home_folder_path`, `shell`: User configuration.
    *   `password`: The password for the keystore.
*   `nodes`: Contains a dictionary of nodes, where the key is the salt minion id.
    *   `node_name`: The name of your node.
    *   `network`: The network to connect to.
    *   `mpt_drive`: The device name of the drive to be used for MPT storage (e.g., `nvme0n1`).
*   `networks`: Defines network-specific details.
    *   `version`: The version of Monad to install (`latest` or a specific version number).
    *   `config_network_name`: The name of the network for configuration files.
    *   `beneficiary`: Your beneficiary address. Make sure to use quotes to indicate a string.

## States

### Deploy State (`deploy.sls`)

The `deploy` state is used to provision a new Monad node from scratch. It performs the following steps:

**Out of scope:**

*   UFW management
*   OTEL installation and config

1.  **Prerequisites and Setup:**
    *   Provisions and formats a dedicated disk for TrieDB storage.
    *   Creates a dedicated user and directory structure for the Monad node.
    *   Adds the necessary APT repository and GPG key for installing Monad.

2.  **Installation and Configuration:**
    *   Installs the Monad software package and places a hold on it to prevent accidental upgrades.
    *   Downloads initial configuration files, including `.env`, `node.toml`, and `validators.toml`.
    *   Generates cryptographic keys (`secp` and `bls`) for the node.
    *   Signs the node's name record.
    *   Updates `node.toml` with the node-specific details.

3.  **Database and Services:**
    *   Fetches the forkpoint and initializes the database.
    *   Fixes hardcoded paths in systemd service files.
    *   Performs a hard reset to restore the node from a snapshot.
    *   Starts and enables all necessary Monad services (`monad-cruft`, `monad-bft`, `monad-execution`, `monad-rpc`).

### Update State (`update.sls`)

The `update` state is used to update an existing Monad node. It performs the following steps:

1.  **Software Update:**
    *   Installs the specified or latest version of the Monad package.
    *   Fixes any hardcoded paths in systemd service files that may have changed with the update.
    *   Starts all Monad services.

### Hard-Reset State (`hard_reset.sls`)

The `hard_reset` state is used to reset Monad node as per [Hard Reset procedure](https://monad-testnet-2-docs.vercel.app/docs/node_reset/hard_reset):

*   Stop stack
*   Reset workspace using script
*   Restore from snapshot using script
*   Download forkpoint and validators file
*   Init MPT database
*   Start stack

### Soft-Reset State (`soft_reset.sls`)

The `soft_reset` state is used to reset Monad node as per [Soft Reset procedure](https://monad-testnet-2-docs.vercel.app/docs/node_reset/soft_reset):

*   Stop stack
*   Download forkpoint and validators file
*   Start stack