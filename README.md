# Monad SaltStack Formulas

This repository contains SaltStack formulas for deploying and managing Monad nodes.

## States

### Deploy State (`deploy.sls`)

The `deploy` state is used to provision a new Monad node from scratch. It performs the following steps:

1.  **Prerequisites and Setup:**
    *   Checks for a `monad` grain on the minion to determine the node type (e.g., `testnet`, `mainnet`).
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

2.  **Reset and Restart:**
    *   Performs a hard reset of the workspace, which includes restoring from a new snapshot.
    *   Starts all Monad services.
