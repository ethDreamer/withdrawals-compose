#!/bin/bash

GENESIS=$(($(date +%s) + 12))
SHANGHAI=$(($GENESIS + 1440))
ETH2_GENESIS=$(($GENESIS + 12))


TESTNET_CONFIG=/shared/testnet
rm -rf $TESTNET_CONFIG
mkdir -p $TESTNET_CONFIG
cp -ra /shared/template/* $TESTNET_CONFIG
sed -i -e 's/XXX/'$SHANGHAI'/' $TESTNET_CONFIG/genesis.json

GENESIS_FILE=$TESTNET_CONFIG/eth2_genesis_time.dat
echo $ETH2_GENESIS > $GENESIS_FILE

echo "MIN_GENESIS_TIME: $ETH2_GENESIS" >> $TESTNET_CONFIG/config.yml

prysmctl \
    testnet \
    generate-genesis \
    --num-validators=512 \
    --output-ssz=$TESTNET_CONFIG/genesis.ssz \
    --chain-config-file=$TESTNET_CONFIG/config.yml \
    --genesis-time=$GENESIS

echo "EIP4844_FORK_EPOCH: 9999999999999" >> $TESTNET_CONFIG/config.yml

