#!/usr/bin/env bash

# make directories
mkdir -p /workspace/bin
mkdir -p /workspace/lnd/.lnd
mkdir -p /workspace/lnd/.lnd2
mkdir -p /workspace/bitcoin/.bitcoin


# Install lnd
wget -O /workspace/bin/lnd-linux-386-v0.7.0-beta-rc2.tar.gz https://github.com/lightningnetwork/lnd/releases/download/v0.7.0-beta-rc2/lnd-linux-amd64-v0.7.0-beta-rc2.tar.gz
tar -xzf /workspace/bin/lnd-linux-386-v0.7.0-beta-rc2.tar.gz  && rm /workspace/bin/lnd-linux-386-v0.7.0-beta-rc2.tar.gz

# Install bitcoind
wget -O /workspace/bin/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.18.0/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz
tar -xzf /workspace/bin/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz && rm /workspace/bin/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz

# Copy conf files
wget -O /workspace/bitcoin/.bitcoin/bitcoin.conf https://github.com/willcl-ark/lnd-grpc/blob/regtest/bitcoin.conf
wget -O /workspace/bitcoin/.lnd/lnd.conf https://github.com/willcl-ark/lnd-grpc/blob/regtest/lnd1.conf
wget -O /workspace/bitcoin/.lnd2/lnd.conf https://github.com/willcl-ark/lnd-grpc/blob/regtest/lnd2.conf
