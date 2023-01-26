#!/bin/sh

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir
ETHERBASE="0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b"

while [ ! -e $TESTNET_CONFIG/genesis.ssz ]; do
    sleep 1
done
sleep 2


rm -rf $DATADIR && \
    mkdir -p $DATADIR


geth \
    --datadir $DATADIR \
    init \
    $TESTNET_CONFIG/genesis.json \

geth \
    --datadir $DATADIR \
    --password <(echo password) \
    --lightkdf \
    account \
    import \
    /shared/sk.json

geth \
    --datadir=$DATADIR \
    --http \
        --http.addr 0.0.0.0 \
        --http.vhosts='*' \
    --networkid 32382 \
    --nodiscover \
    --syncmode=full \
    --password <(echo password) \
    --allow-insecure-unlock \
    --miner.etherbase $ETHERBASE \
    --unlock $ETHERBASE \
    --mine \
        --authrpc.addr 0.0.0.0 \
        --authrpc.vhosts='*' \
    --authrpc.jwtsecret=/shared/jwt.secret



