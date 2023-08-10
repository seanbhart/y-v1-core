# Y - The Everything Protocol

Y World Computer Open Social Standard

## Contract Structure

Yeets are social actions. All actions are Yeets.

Yeets always save data to Y contracts (accounts). Normal Yeeting uses a "yeet" function. Yo contracts must also have a
"save" function that will be called by the Y contract to allow the Yo module to save data internally if needed.

### Y Social Components

- **Y.sol** / **Yme.sol** - A generalized account contract
- **Yo.sol** - A generalized short-form text yeet contract
- **Ya.sol** - A generalized short-form text reyeet contract (for any yeet type)
- **Yot.sol** - A generalized emoji reaction contract (for any yeet type)
- **Yikes.sol** - A generalized long-form text yeet contract
- **Yolo.sol** - A generalized photo yeet contract
- **Yap.sol** - A generalized audio yeet contract

- **Yi.sol** -
- **Ye.sol** -
- **Yu.sol** -
- **Yup.sol** -
- **Yum.sol** -
- **Yay.sol** -
- **Yuck.sol** -
- **Yell.sol** -
- **Ytho.sol** -
- **Ynot.sol** -
- **Ynow.sol** -
- **Ybother.sol** -
- **Ywait.sol** -
- **Ystop.sol** -
- **Yyoudothat.sol** -
- **Yyouthisway.sol** -
- **Ysoserious.sol** -
- **Ymca.sol** -
- **justY.sol** -
- **butY.sol** -
- **Yframe.sol** -
- **Yrush.sol** -
- **Yard.sol** -
- **Yapper.sol** -
- **Yacht.sol** -

#### Y Social Components by Type

- **Account** - Y.sol
- **Text** - Yo.sol, Ya.sol, Yrush.sol, justY.sol
- **Photo** - Yolo.sol, Ya.sol, justY.sol
- **Audio** - Yapper.sol, Ya.sol, justY.sol
- **Video** -

## Setup & Common Commands

### Compile

Compile the smart contracts with Hardhat:

```sh
$ hh compile
```

### TypeChain

Compile the smart contracts and generate TypeChain bindings:

```sh
$ hh typechain
```

### Test

Run the tests with Hardhat:

```sh
$ hh test
```

### Lint Solidity

Lint the Solidity code:

```sh
$ npm lint:sol
```

### Lint TypeScript

Lint the TypeScript code:

```sh
$ npm lint:ts
```

### Coverage

Generate the code coverage report:

```sh
$ npm coverage
```

### Report Gas

See the gas usage per unit test and average gas per method call:

```sh
$ REPORT_GAS=true npm test
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```sh
$ npm clean
```

### Deploy

Deploy the contracts to Hardhat Network:

```sh
$ hh deploy:contracts"
```
