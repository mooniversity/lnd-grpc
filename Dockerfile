FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

# Update bashrc
RUN echo "alias python='python3'" >> $HOME/.bashrc \
    && echo "alias pip='pip3'" >> $HOME/.bashrc \
    && echo "alias lnd='/workspace/lnd-linux-386-v0.6.1-beta/lnd --lnddir=/workspace/lnd/.lnd --datadir=/workspace/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.addpeer=btcd-testnet.lightning.computer'" >> $HOME/.bashrc
