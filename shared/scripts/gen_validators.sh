#!/bin/bash

get_config_param () {
    local config=$1
    local param=$2

    grep "${param}:" $config | cut -d' ' -f2
}

TESTNET_DIRECTORY=/shared/testnet
FINISHED_FILE=$TESTNET_DIRECTORY/finished.dat

# block until genstate.sh is finished setting up testnet directory
while [ ! -e $FINISHED_FILE ]; do
    sleep 1
done
rm $FINISHED_FILE

CONFIG_YAML=$TESTNET_DIRECTORY/config.yml
MIN_GENESIS_TIME=$(get_config_param $CONFIG_YAML MIN_GENESIS_TIME)
ALTAIR_FORK_EPOCH=$(get_config_param $CONFIG_YAML ALTAIR_FORK_EPOCH)
MERGE_FORK_EPOCH=$(get_config_param $CONFIG_YAML BELLATRIX_FORK_EPOCH)
DEPOSIT_ADDRESS=$(get_config_param $CONFIG_YAML DEPOSIT_CONTRACT_ADDRESS)
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

DATADIR=/datadir
rm -rf $DATADIR

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


