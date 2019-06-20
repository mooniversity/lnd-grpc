FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

RUN pip install lnd_grpc

# Update bashrc
RUN echo "alias python='python3'" >> $HOME/.bashrc \
    && echo "alias pip='pip3'" >> $HOME/.bashrc \
    && echo "alias lnd='/workspace/lnd-linux-386-v0.6.1-beta/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.addpeer=btcd-testnet.lightning.compute'" >> $HOME/.bashrc

# Install neutrino
RUN wget https://github.com/lightningnetwork/lnd/releases/download/v0.6.1-beta/lnd-linux-386-v0.6.1-beta.tar.gz
RUN tar -xzf ./lnd-linux-386-v0.6.1-beta.tar.gz

