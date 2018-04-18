### Backend App for Umblocks

## Getting Started

# Prerequisites

You need to have installed ganache-cli and truffle framework to test this project

# Setup

Start a testing RPC using this command:

```
ganache-cli --port 7545 --accounts 5 --gasPrice 0 --networkId 5777
```

Compile & migrate the contracts:

```
truffle compile
truffle migrate
```

Finally, execute the scripts to set up the environment:

```
truffle exec scripts/initialregister.js
truffle exec scripts/add_sandbox_data.js
```

# Testing

Once you have started the network with ganache-cli, you can execute the tests using the following command:

```
truffle test
```
