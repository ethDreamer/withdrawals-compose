#!/bin/sh

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir

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

echo -e "\n" | geth \
    --datadir $DATADIR \
    account \
    import \
    /shared/sk.json

echo -e "\n\n" | geth \
    --datadir=$DATADIR \
    --http \
	--http.addr 0.0.0.0 \
	--http.vhosts='*' \
    --networkid 32382 \
    --nodiscover \
    --syncmode=full \
    --allow-insecure-unlock \
    --unlock "0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b" \
    --mine \
	--authrpc.addr 0.0.0.0 \
	--authrpc.vhosts='*' \
    --authrpc.jwtsecret=/shared/jwt.secret



