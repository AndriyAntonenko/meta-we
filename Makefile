-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil deploy-anvil deploy-sepolia erigon deploy-erigon

DEFAULT_ERIGON_KEY := 0x26e86e45f6fc45ec6e2ecd128cec80fa1d1505e5507dcd2ae58c3130a7a97b48
DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: remove build test

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit 

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 10 --chain-id 1337

coverage :; forge coverage 

coverage-report :; forge coverage --report debug > coverage-report.txt

slither :; slither . --config-file slither.config.json 

deploy-anvil :; forge script script/Deploy.s.sol \
	--private-key ${DEFAULT_ANVIL_KEY} \
	--rpc-url http://localhost:8545 \
	--broadcast

deploy-sepolia :; forge script script/Deploy.s.sol \
	--private-key ${SEPOLIA_DEPLOYER_PRIVATE_KEY} \
	--rpc-url ${SEPOLIA_RPC_URL} \
	--broadcast

erigon :; docker compose -f ./infra/local/docker-compose.yml up

deploy-erigon :; forge script script/Deploy.s.sol \
	--private-key ${DEFAULT_ERIGON_KEY} \
	--rpc-url http://localhost:8545 \
	--broadcast
