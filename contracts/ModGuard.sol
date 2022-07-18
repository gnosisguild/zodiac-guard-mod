// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.6;

import "@gnosis.pm/zodiac/contracts/interfaces/IAvatar.sol";
import "@gnosis.pm/zodiac/contracts/guard/BaseGuard.sol";
import "@gnosis.pm/zodiac/contracts/factory/FactoryFriendly.sol";
import "@gnosis.pm/safe-contracts/contracts/common/StorageAccessible.sol";

contract ModGuard is FactoryFriendly, BaseGuard {
    event ModGuardSetup(
        address indexed initiator,
        address indexed owner,
        address[] modules
    );
    event ProtectedModulesSet(address[] protectedModules);

    // Cannot disable this guard
    error CannotDisableThisGuard(address guard);

    // Cannot disable protected modules
    error CannotDisableProtecedModules(address module);

    address[] public protectedModules;

    // keccak256("guard_manager.guard.address")
    bytes32 internal constant GUARD_STORAGE_SLOT =
        0x4a204f620c8c5ccdca3fd54d003badd85ba500436a431f0cbda4f558c93c34c8;

    constructor(address _owner, address[] memory _modules) {
        bytes memory initializeParams = abi.encode(_owner, _modules);
        setUp(initializeParams);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override {
        __Ownable_init();
        (address _owner, address[] memory _modules) = abi.decode(
            initializeParams,
            (address, address[])
        );

        setProtectedModules(_modules);
        transferOwnership(_owner);

        emit ModGuardSetup(msg.sender, _owner, _modules);
    }

    function setProtectedModules(address[] memory _modules) public onlyOwner {
        protectedModules = _modules;
        emit ProtectedModulesSet(protectedModules);
    }

    // solhint-disallow-next-line payable-fallback
    fallback() external {
        // We don't revert on fallback to avoid issues in case of a Safe upgrade
        // E.g. The expected check method might change and then the Safe would be locked.
    }

    function checkTransaction(
        address,
        uint256,
        bytes memory,
        Enum.Operation,
        uint256,
        uint256,
        uint256,
        address,
        // solhint-disallow-next-line no-unused-vars
        address payable,
        bytes memory,
        address
    ) external view override {}

    function checkAfterExecution(bytes32, bool) external view override {
        if (
            abi.decode(
                StorageAccessible(msg.sender).getStorageAt(
                    uint256(GUARD_STORAGE_SLOT),
                    2
                ),
                (address)
            ) != address(this)
        ) {
            revert CannotDisableThisGuard(address(this));
        }
        for (uint256 i = 0; i < protectedModules.length; i++) {
            if (!IAvatar(msg.sender).isModuleEnabled(protectedModules[i])) {
                revert CannotDisableProtecedModules(protectedModules[i]);
            }
        }
    }
}
