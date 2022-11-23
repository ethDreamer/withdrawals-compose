#!/bin/bash

TESTNET_CONFIG=/shared/testnet

GENESIS_FILE=$TESTNET_CONFIG/eth2_genesis_time.dat
CONFIG_FILE=$TESTNET_CONFIG/config.yml
DATADIR=/datadir

while [ ! -e $GENESIS_FILE ]; do
    sleep 1
done

ETH2_GENESIS=$(cat $GENESIS_FILE)
LCLI_BIN=/home/mark/ethereum/development/lighthouse/target/release/lcli

ALTAIR_FORK_EPOCH=$(cat $CONFIG_FILE | grep ALTAIR_FORK_EPOCH    | cut -d' ' -f2)
MERGE_FORK_EPOCH=$(cat  $CONFIG_FILE | grep BELLATRIX_FORK_EPOCH | cut -d' ' -f2)
DEPOSIT_ADDRESS=$(cat   $CONFIG_FILE | grep DEPOSIT_CONTRACT_ADDRESS | cut -d ' ' -f2)

rm -rf $DATADIR

GENESIS_BLOCK_HASH=$(curl -s \
	-X \
	POST \
	-H "Content-Type: application/json" \
	--data \
	'{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["earliest",false],"id":1}' \
	http://execution:8545 \
	| jq '.result.hash' \
	| tr -d '"')

echo "GENESIS_BLOCK_HASH: $GENESIS_BLOCK_HASH"


echo lcli \
    --spec mainnet \
    new-testnet \
    --genesis-time $ETH2_GENESIS \
    --altair-fork-epoch $ALTAIR_FORK_EPOCH \
    --merge-fork-epoch $MERGE_FORK_EPOCH \
    --interop-genesis-state \
    --validator-count 512 \
    --min-genesis-active-validator-count 512 \
    --testnet-dir $DATADIR \
	--deposit-contract-address $DEPOSIT_ADDRESS \
	--deposit-contract-deploy-block 0 \
	--eth1-block-hash $GENESIS_BLOCK_HASH

lcli \
    --spec mainnet \
    new-testnet \
    --genesis-time $ETH2_GENESIS \
    --altair-fork-epoch $ALTAIR_FORK_EPOCH \
    --merge-fork-epoch $MERGE_FORK_EPOCH \
    --interop-genesis-state \
    --validator-count 512 \
    --min-genesis-active-validator-count 512 \
    --testnet-dir $DATADIR \
	--deposit-contract-address $DEPOSIT_ADDRESS \
	--deposit-contract-deploy-block 0 \
	--eth1-block-hash $GENESIS_BLOCK_HASH

lcli \
	insecure-validators \
	--count 512 \
	--base-dir $DATADIR \
	--node-count 1

mv $DATADIR/node_1/validators $DATADIR && mv $DATADIR/node_1/secrets $DATADIR && rmdir $DATADIR/node_1


