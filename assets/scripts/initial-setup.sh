#!/usr/bin/env bash

# Install lnd
mkdir /workspace/bin && cd /workspace/bin
wget -O lnd-linux-386-v0.7.0-beta-rc2.tar.gz https://github.com/mooniversity/lnd-grpc/releases/download/1.1/lnd-linux-386-v0.7.0-beta-rc2.tar.gz
tar -xzf lnd-linux-386-${LND_VERSION}.tar.gz && rm lnd-linux-386-${LND_VERSION}.tar.gz

