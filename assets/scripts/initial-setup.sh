#!/usr/bin/env bash

# make directories
mkdir -p /workspace/bin
mkdir -p /workspace/lnd/.lnd
mkdir -p /workspace/lnd/.lnd2
mkdir -p /workspace/bitcoin/.bitcoin

cd /workspace/bin

# Install lnd
wget -O lnd-linux-386-v0.7.0-beta-rc2.tar.gz https://github.com/lightningnetwork/lnd/releases/download/v0.7.0-beta-rc2/lnd-linux-amd64-v0.7.0-beta-rc2.tar.gz
tar -xzf lnd-linux-386-v0.7.0-beta-rc2.tar.gz  && rm lnd-linux-386-v0.7.0-beta-rc2.tar.gz

# Install bitcoind
wget -O bitcoin-0.18.0-x86_64-linux-gnu.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.18.0/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz
tar -xzf bitcoin-0.18.0-x86_64-linux-gnu.tar.gz && rm bitcoin-0.18.0-x86_64-linux-gnu.tar.gz

# Copy conf files
cd /workspace/bitcoin/.bitcoin && wget -O bitcoin.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/bitcoin.conf
cd /workspace/lnd/.lnd && wget -O lnd.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/lnd1.conf
cd /workspace/lnd/.lnd2 && wget -O lnd.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/lnd2.conf
