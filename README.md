# Warning
**This contract is under development and is unsafe to use in its current form. Check back soon**

# ModGuard

[![Build Status](https://github.com/gnosis/zodiac-guard-mod/actions/workflows/ci.yml/badge.svg)](https://github.com/gnosis/zodiac-guard-mod/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/gnosis/zodiac-guard-mod/badge.svg?branch=main)](https://coveralls.io/github/gnosis/zodiac-guard-mod)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](https://github.com/gnosis/CODE_OF_CONDUCT)

A transaction guard that allows the owner to guard against transactions that would disable protected mods.

### Features

- Set protected mods
- Any guarded transaction that disables a protected mod will revert.

### Flow

- Deploy ModGuard
- Enable the ModGuard in the Safe or on another module

### Solidity Compiler

The contracts have been developed with [Solidity 0.8.6](https://github.com/ethereum/solidity/releases/tag/v0.8.6) in mind. This version of Solidity made all arithmetic checked by default, therefore eliminating the need for explicit overflow or underflow (or other arithmetic) checks.

### Security and Liability

All contracts are WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

### License

Created under the [LGPL-3.0+ license](LICENSE).
