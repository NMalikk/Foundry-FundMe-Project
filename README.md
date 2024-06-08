
# Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Foundry Notes

### Deploying Contracts

#### Deploying Contract Through Script on Local Chain
```shell
forge script script/DeploySimpleStorage.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --private-key <private_key here> #DONOT USE AS ITS NOT GOOD TO HAVE PRIVATE KEY IN PLAIN TEXT!
```

#### Deploying Contract Directly (No Script)
```shell
forge create SimpleStorage --rpc-url http://127.0.0.1:8545 --interactive
```

#### Deploying Contract Using Scripts Safely (Not ENV, Using Cast Wallet Imports/Key Store)
```shell
forge script script/DeploySimpleStorage.s.sol --rpc-url $RPC_URL --account defaultKey --sender 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --broadcast
```
Note: `sender` means the address of whatever private key you are using.

#### Creating a Key Store Wallet
Use the following command to create a key store wallet:
```shell
cast wallet import <your_key/account_name> --interactive
```
Example:
```shell
cast wallet import HasSepolia --interactive
```
Casted wallets:
- `defaultKey`: account on anvil key (first one).
- `HasSepolia`: testing wimpy.

### Interacting with Contracts

Using `cast call` and `cast send`

- **`cast call`**: No cost since it's read-only.
```shell
cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "retrieve()"
```

- **`cast send`**: Costs gas since writing is required.
```shell
cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "store(uint256)" 69 --interactive
```

### Creating a Project in Foundry

#### Create folders:
```shell
forge init
```

### Running Tests

Remember that when you don't specify an RPC URL, Forge runs a local chain on Anvil and performs your tests on it. This can be a problem, especially when trying to use Chainlink (price feed, etc.).

Therefore, you need to provide a fork URL so that the simulation can ensure it simulates a local blockchain acting as this RPC URL:
```shell
forge test -m <function name> -vvv --fork-url $SEPOLIA_RPC_URL_FROM_ALCHEMY
```

### Knowing How Many Tests You Have Written (Test Coverage)

```shell
forge coverage --fork-url $RPC_URL
```

### Forking: Giving Your Local Blockchain (Anvil) Access to Chainlink Oracles (e.g., Price Feeds)
```shell
forge test -vvvv --mt testPriceFeedVersion --fork-url $SEPOLIA_RPC_URL  // mt here is to run a specific test only and -vvvv is visibility. Alchemy provides rpc.
```

### Foundry Cheatcodes

- **prank**: Sets the address for the next transaction.
- **deal**: Give this address/user some money to work with.
- **expect revert**: So we can check if the next line reverts.
- **hoax**: Does prank + deal together.
- **vm.startPrank / vm.endPrank**: Act the same as broadcast.

By default, Anvil gas price = 0
- **vm.transaction**: Sets the gas price for the next transaction.
- **gasleft()**: Returns the amount of gas left for the current transaction.

### Storage

Helps optimization of gas. Remember, reading/writing from storage costs more than reading/writing from memory (local).

### Makefile

Helps in running of scripts/deployment without having to write commands too much.

### Verification from Etherscan

```shell
--verify --etherscan-api-key $YOUR_ETHERSCAN_API_KEY
```

## Credits

This project was developed as part of the Foundry Fund Me course by [Cyfrin](https://github.com/Cyfrin/foundry-fund-me-f23). Special thanks to Cyfrin for providing the course materials and guidance.

