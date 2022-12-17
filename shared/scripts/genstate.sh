#!/bin/bash

setup_testnet_directory () {
    local td=$1
    rm -rf $td
    mkdir -p $td
    cp -ra /shared/template/* $td
}

get_config_param () {
    local config=$1
    local param=$2

    grep "${param}:" $config | cut -d' ' -f2
}

set_config_param () {
    local config=$1
    local param=$2
    local value=$3
    sed -i -e "s/${param}.*/${param}: $value/" $config
}


TESTNET_DIRECTORY=/shared/testnet
setup_testnet_directory $TESTNET_DIRECTORY

CONFIG_YAML=$TESTNET_DIRECTORY/config.yml
MIN_GENESIS_TIME=$(($(date +%s) + 30))
set_config_param $CONFIG_YAML MIN_GENESIS_TIME $MIN_GENESIS_TIME

CAPELLA_FORK_EPOCH=$(get_config_param $CONFIG_YAML CAPELLA_FORK_EPOCH)
SECONDS_PER_SLOT=$(get_config_param $CONFIG_YAML SECONDS_PER_SLOT)
SLOTS_PER_EPOCH=$(get_config_param $CONFIG_YAML SLOTS_PER_EPOCH)
SHANGHAI_TIME=$(($MIN_GENESIS_TIME + $CAPELLA_FORK_EPOCH * $SECONDS_PER_SLOT * $SLOTS_PER_EPOCH))
# edit one param in genesis.json
sed -i -e "s/SHANGHAI_TIME/${SHANGHAI_TIME}/" $TESTNET_DIRECTORY/genesis.json

FINISHED_FILE=$TESTNET_DIRECTORY/finished.dat
touch $FINISHED_FILE

prysmctl \
    testnet \
    generate-genesis \
    --num-validators=512 \
    --output-ssz=$TESTNET_DIRECTORY/genesis.ssz \
    --chain-config-file=$TESTNET_DIRECTORY/config.yml \
    --genesis-time=$MIN_GENESIS_TIME


