#!/usr/bin/env bash

# Install lnd
mkdir /workspace/bin && cd /workspace/bin
wget -O lnd-linux-386-v0.7.0-beta-rc2.tar.gz https://www.dropbox.com/s/pfu5myums1x4h88/lnd-linux-386-v0.7.0-beta-rc2.tar.gz?dl=0
tar -xzf lnd-linux-386-${LND_VERSION}.tar.gz && rm lnd-linux-386-${LND_VERSION}.tar.gz

