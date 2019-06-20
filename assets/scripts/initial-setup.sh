# Install lnd
cd /workspace
wget https://github.com/lightningnetwork/lnd/releases/download/v0.6.1-beta/lnd-linux-386-v0.6.1-beta.tar.gz
tar -xzf ./lnd-linux-386-v0.6.1-beta.tar.gz

# Install python libs
pip3 install lnd_grpc
