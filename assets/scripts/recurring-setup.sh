# Symlink datadir to homedir
ln -s /workspace/lnd/.lnd /home/gitpod/.lnd

# Run LND
/workspace/lnd-linux-386-v0.6.1-beta/lnd --lnddir=/workspace/lnd/.lnd --datadir=/workspace/lnd --bitcoin.active --bitcoin.testnet --debuglevel=info --bitcoin.node=neutrino --neutrino.addpeer=btcd-testnet.lightning.computer
