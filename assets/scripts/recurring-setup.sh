# Symlink datadir to homedir
ln -s /workspace/lnd/.lnd /home/gitpod/.lnd

# Run LND
/workspace/bin/lnd-linux-386-${LND_VERSION}/lnd --lnddir=/workspace/lnd/.lnd --datadir=/workspace/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.addpeer=btcd-testnet.lightning.computer
