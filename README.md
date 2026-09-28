# minimal-erc20

An ERC-20 token in about 100 lines, written without OpenZeppelin so the whole thing can be read in one
file.

What's in it:

- `transfer`, `approve` and `transferFrom` with the `Transfer` and `Approval` events
- an allowance of `type(uint256).max` counts as infinite and is never decremented, which saves an
  SSTORE per `transferFrom`
- `mint` for the owner, `burn` for anyone's own tokens, and `transferOwnership`
- custom errors instead of revert strings
- `unchecked` only where overflow can't happen (no balance can exceed the total supply)

## Build and test

```bash
forge build
forge test -vv
```

The tests don't use `forge-std`. The few cheatcodes they need are declared in `test/Vm.sol`, so there
is nothing to install after cloning.

## Deploy

```bash
forge create src/Token.sol:Token --rpc-url $RPC_URL --private-key $PK \
  --constructor-args "My Token" MTK 1000000000000000000000000
```

Not audited. Get a review before it holds anything of value.
