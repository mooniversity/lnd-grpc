FROM gitpod/workspace-full:latest
USER root

WORKDIR /workspace

# set the LND version to be installed and referenced throughout the workspace here
ENV LND_VERSION "v0.7.0-beta-rc2"
ENV BITCOIN_REGTEST "/workspace/bitcoin/.bitcoin"
RUN echo "export LND_VERSION='v0.7.0-beta-rc2'" >> $HOME/.bashrc
RUN echo "export BITCOIN_REGTEST='/workspace/bitcoin/.bitcoin'" >> $HOME/.bashrc
RUN /bin/bash -c  'source $HOME/.bashrc'

# add aliases
RUN echo "alias python='python3'" >> $HOME/.bash_aliases \
    && echo "alias pip='pip3'" >> $HOME/.bash_aliases  \
    && echo "alias lnd1='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lnd --lnddir=/workspace/lnd/.lnd --routing.assumechanvalid 1'" >> $HOME/.bash_aliases  \
    && echo "alias lnd2='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lnd --lnddir=/workspace/lnd/.lnd2 --routing.assumechanvalid 1'" >> $HOME/.bash_aliases  \
    && echo "alias alice='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lncli --network regtest --lnddir /workspace/lnd/.lnd'" >> $HOME/.bash_aliases  \
    && echo "alias bob='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lncli --network regtest --lnddir /workspace/lnd/.lnd2 --rpcserver=localhost:11009'" >> $HOME/.bash_aliases  \
    && echo "alias bitcoind='/workspace/bin/bitcoin-0.18.0/bin/bitcoind -datadir=/workspace/bitcoin/.bitcoin'" >> $HOME/.bash_aliases  \
    && echo "alias bitcoin-cli='/workspace/bin/bitcoin-0.18.0/bin/bitcoin-cli -datadir=/workspace/bitcoin/.bitcoin'" >> $HOME/.bash_aliases

# source aliases
RUN /bin/bash -c 'source $HOME/.bashrc'
