
# Install lnd
RUN wget https://github.com/lightningnetwork/lnd/releases/download/v0.6.1-beta/lnd-linux-386-v0.6.1-beta.tar.gz
RUN tar -xzf ./lnd-linux-386-v0.6.1-beta.tar.gz
mv lnd-linux-386-v0.6.1-beta.tar.gz /workspace

# Install python libs
pip3 install lnd_grpc
