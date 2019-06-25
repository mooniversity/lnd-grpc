FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

# set the LND version to be installed and referenced throughout the workspace here
ENV LND_VERSION "v0.7.0-beta-rc2"
RUN echo "export LND_VERSION='v0.7.0-beta-rc2.'" >> $HOME/.bashrc
RUN /bin/bash -c  'source $HOME/.bashrc'

# add aliases
RUN echo "alias python='python3'" >> $HOME/.bashrc \
    && echo "alias pip='pip3'" >> $HOME/.bashrc \
    && echo "alias lnd='/workspace/bin/lnd-linux-386-${LND_VERSION}/lnd --lnddir=/workspace/lnd/.lnd --datadir=/workspace/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.connect=btcd-testnet.lightning.computer --routing.assumechanvalid 1'" >> $HOME/.bashrc \
    && echo "alias lncli='/workspace/bin/lnd-linux-386-${LND_VERSION}/lncli --network testnet --lnddir /workspace/lnd/.lnd'" >> $HOME/.bashrc
