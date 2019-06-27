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
RUN echo "alias python='python3'" >> $HOME/.bash_aliases
RUN echo "alias pip='pip3'" >> $HOME/.bash_aliases
RUN echo "alias lnd1='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lnd --lnddir=/workspace/lnd/.lnd --routing.assumechanvalid 1'" >> $HOME/.bash_aliases
RUN echo "alias lnd2='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lnd --lnddir=/workspace/lnd/.lnd2 --routing.assumechanvalid 1'" >> $HOME/.bash_aliases
RUN echo "alias alice='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lncli --network regtest --lnddir /workspace/lnd/.lnd'" >> $HOME/.bash_aliases
RUN echo "alias bob='/workspace/bin/lnd-linux-amd64-v0.7.0-beta-rc2/lncli --network regtest --lnddir /workspace/lnd/.lnd2 --rpcserver=localhost:11009'" >> $HOME/.bash_aliases
RUN echo "alias bitcoind='/workspace/bin/bitcoin-0.18.0/bin/bitcoind -datadir=/workspace/bitcoin/.bitcoin'" >> $HOME/.bash_aliases
RUN echo "alias bitcoin-cli='/workspace/bin/bitcoin-0.18.0/bin/bitcoin-cli -datadir=/workspace/bitcoin/.bitcoin'" >> $HOME/.bash_aliases

# source aliases
RUN /bin/bash -c 'source $HOME/.bashrc'

# make directories
RUN mkdir -p /workspace/bin
RUN mkdir -p /workspace/lnd/.lnd
RUN mkdir -p /workspace/lnd/.lnd2
RUN mkdir -p /workspace/bitcoin/.bitcoin

RUN cd /workspace/bin
RUN wget -O lnd-linux-386-v0.7.0-beta-rc2.tar.gz https://github.com/lightningnetwork/lnd/releases/download/v0.7.0-beta-rc2/lnd-linux-amd64-v0.7.0-beta-rc2.tar.gz
RUN tar -xzf lnd-linux-386-v0.7.0-beta-rc2.tar.gz  && rm lnd-linux-386-v0.7.0-beta-rc2.tar.gz
RUN wget -O bitcoin-0.18.0-x86_64-linux-gnu.tar.gz https://bitcoincore.org/bin/bitcoin-core-0.18.0/bitcoin-0.18.0-x86_64-linux-gnu.tar.gz
RUN tar -xzf bitcoin-0.18.0-x86_64-linux-gnu.tar.gz && rm bitcoin-0.18.0-x86_64-linux-gnu.tar.gz
RUN cd /workspace/bitcoin/.bitcoin && wget -O bitcoin.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/bitcoin.conf
RUN cd /workspace/lnd/.lnd && wget -O lnd.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/lnd1.conf
RUN cd /workspace/lnd/.lnd2 && wget -O lnd.conf https://raw.githubusercontent.com/willcl-ark/lnd-grpc/regtest/lnd2.conf