FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

# set the LND version to be installed and referenced throughout the workspace here
ENV LND_VERSION "v0.7.0-beta-rc2"
ENV BITCOIN_REGTEST "/workspace/bitcoin/.bitcoin"
RUN echo "export LND_VERSION='v0.7.0-beta-rc2'" >> $HOME/.bashrc
RUN echo "export BITCOIN_REGTEST='/workspace/bitcoin/.bitcoin;" >> $HOME/.bashrc
RUN /bin/bash -c  'source $HOME/.bashrc'

# add aliases
RUN echo "alias python='python3'" >> $HOME/.bashrc \
    && echo "alias pip='pip3'" >> $HOME/.bashrc \
    && echo "alias lnd1='/workspace/bin/lnd-linux-386-${LND_VERSION}/lnd --lnddir=/workspace/lnd/.lnd --routing.assumechanvalid 1'" >> $HOME/.bashrc \
    && echo "alias lnd2='/workspace/bin/lnd-linux-386-${LND_VERSION}/lnd --lnddir=/workspace/lnd/.lnd2 --routing.assumechanvalid 1'" >> $HOME/.bashrc \
    && echo "alias alice='/workspace/bin/lnd-linux-386-${LND_VERSION}/lncli --network regtest --lnddir /workspace/lnd/.lnd'" >> $HOME/.bashrc \
    && echo "alias bob='/workspace/bin/lnd-linux-386-${LND_VERSION}/lncli --network regtest --lnddir /workspace/lnd/.lnd2 --rpcserver=localhost:11009'" >> $HOME/.bashrc \
    && echo "alias bitcoind='/workspace/bin/bitcoind -datadir=${BITCOIN_REGTEST}'" >> $HOME/.bashrc \
    && echo "alias bitcoin-cli='/workspace/bin/bitcoin-cli -datadir=${BITCOIN_REGTEST}'" >> $HOME/.bashrc
