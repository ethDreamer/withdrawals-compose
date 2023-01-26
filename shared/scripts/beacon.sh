#!/bin/bash

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir


while [ ! -e $TESTNET_CONFIG/genesis.ssz ]; do
    sleep 1
done
sleep 2


rm -rf $DATADIR && \
    mkdir -p $DATADIR/testnet && \
    cd $DATADIR/testnet && \
    echo "[]" > ./boot_enr.yaml && \
    ln -sf $TESTNET_CONFIG/config.yml ./config.yaml && \
    echo "0" > deploy_block.txt && \
    ln -sf $TESTNET_CONFIG/genesis.ssz . \
    && cd /


lighthouse \
    --datadir=$DATADIR \
    --testnet-dir=$DATADIR/testnet \
    beacon \
    --http-allow-sync-stalled \
    --disable-enr-auto-update \
    --dummy-eth1 \
    --http \
    --http-address=0.0.0.0 \
    --jwt-secrets=/shared/jwt.secret \
    --execution-endpoint=http://proxy:8551

