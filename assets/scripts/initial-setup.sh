#!/usr/bin/env bash

# Install lnd
mkdir /workspace/bin && cd /workspace/bin
wget https://github.com/lightningnetwork/lnd/releases/download/${LND_VERSION}/lnd-linux-386-${LND_VERSION}.tar.gz
tar -xzf lnd-linux-386-${LND_VERSION}.tar.gz && rm lnd-linux-386-${LND_VERSION}.tar.gz

