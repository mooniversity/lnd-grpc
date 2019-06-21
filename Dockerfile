FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

# set the LND version to be installed and referenced throughout the workspace here
RUN echo "export LND_VERSION='v0.6.1-beta'" >> $HOME/.bashrc \
    && source $HOME/.bashrc

# add aliases
RUN echo "alias python='python3'" >> $HOME/.bashrc \
    && echo "alias pip='pip3'" >> $HOME/.bashrc \
    && echo "alias lnd='/workspace/bin/lnd-linux-386-${LND_VERSION}/lnd --lnddir=/workspace/lnd/.lnd --datadir=/workspace/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.connect=btcd-testnet.lightning.computer'" >> $HOME/.bashrc \
    && echo "alias lncli='/workspace/bin/lnd-linux-386-${LND_VERSION}/lncli --network testnet --lnddir /workspace/lnd/.lnd'" >> $HOME/.bashrc

