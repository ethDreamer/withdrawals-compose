#!/bin/bash

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir

while [ ! -e $TESTNET_CONFIG/genesis.ssz ]; do
    sleep 1
done
sleep 2

/shared/scripts/gen_validators.sh

mkdir -p $DATADIR/testnet && \
    cd $DATADIR/testnet && \
    echo "[]" > ./boot_enr.yaml && \
    ln -sf $TESTNET_CONFIG/config.yml ./config.yaml && \
    echo "0" > deploy_block.txt && \
    ln -sf $TESTNET_CONFIG/genesis.ssz . \
    && cd /


lighthouse \
    --spec mainnet \
    --datadir=$DATADIR \
    --testnet-dir=$DATADIR/testnet \
    validator \
    --suggested-fee-recipient=0x25c4a76E7d118705e7Ea2e9b7d8C59930d8aCD3b \
    --init-slashing-protection \
    --beacon-nodes http://beacon:5052 \

