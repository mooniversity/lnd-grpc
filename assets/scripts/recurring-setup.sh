# Symlink datadir to homedir
ln -s /workspace/lnd/.lnd /home/gitpod/.lnd

# Start bitcoind
/workspace/bin/bitcoin-0.18.0/bin/bitcoind -datadir=/workspace/bitcoin/.bitcoin