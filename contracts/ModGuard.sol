// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.6;

import "@gnosis.pm/zodiac/contracts/interfaces/IAvatar.sol";
import "@gnosis.pm/zodiac/contracts/guard/BaseGuard.sol";
import "@gnosis.pm/zodiac/contracts/factory/FactoryFriendly.sol";

contract ModGuard is FactoryFriendly, BaseGuard {
    event ModGuardSetup(
        address indexed initiator,
        address indexed owner,
        address indexed avatar,
        address[] modules
    );
    event ProtectedModulesSet(address[] protectedModules);
    event AvatarSet(address avatar);

    address public avatar;
    address[] public protectedModules;

    constructor(
        address _owner,
        address _avatar,
        address[] memory _modules
    ) {
        bytes memory initializeParams = abi.encode(_owner, _avatar, _modules);
        setUp(initializeParams);
    }

    /// @dev Initialize function, will be triggered when a new proxy is deployed
    /// @param initializeParams Parameters of initialization encoded
    function setUp(bytes memory initializeParams) public override {
        __Ownable_init();
        (address _owner, address _avatar, address[] memory _modules) = abi
            .decode(initializeParams, (address, address, address[]));

        avatar = _avatar;
        setProtectedModules(_modules);
        transferOwnership(_owner);

        emit ModGuardSetup(msg.sender, _owner, _avatar, _modules);
    }

    function setProtectedModules(address[] memory _modules) public onlyOwner {
        protectedModules = _modules;
        emit ProtectedModulesSet(protectedModules);
    }

    function setAvatar(address _avatar) public onlyOwner {
        avatar = _avatar;
        emit AvatarSet(avatar);
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
        for (uint256 i = 0; i < protectedModules.length; i++) {
            require(
                IAvatar(avatar).isModuleEnabled(protectedModules[i]),
                "Cannot disable protected modules"
            );
        }
    }
}
