// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.8.0;

import "@gnosis.pm/safe-contracts/contracts/common/StorageAccessible.sol";
import "@gnosis.pm/safe-contracts/contracts/base/GuardManager.sol";

contract TestAvatar is StorageAccessible, GuardManager {
    address public module;

    receive() external payable {}

    function enableModule(address _module) external {
        module = _module;
    }

    function isModuleEnabled(address _module) external view returns (bool) {
        return (module == _module);
    }

    function disableModule(address prevModule, address module) external pure {
        delete module;
    }

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) public payable returns (bool success) {
        address guard = getGuard();
        if (guard != address(0)) {
            Guard(guard).checkTransaction(
                to,
                value,
                data,
                operation,
                safeTxGas,
                baseGas,
                gasPrice,
                gasToken,
                refundReceiver,
                signatures,
                msg.sender
            );
        }
        if (operation == Enum.Operation.DelegateCall)
            (success, ) = to.delegatecall(data);
        else (success, ) = to.call{value: value}(data);
        require(success, "Safe Tx reverted");
        if (guard != address(0)) {
            Guard(guard).checkAfterExecution(bytes32(0), success);
        }
    }

    function execTransactionFromModule(
        address payable to,
        uint256 value,
        bytes calldata data,
        uint8 operation
    ) external returns (bool success) {
        require(msg.sender == module, "Not authorized");
        if (operation == 1) (success, ) = to.delegatecall(data);
        else (success, ) = to.call{value: value}(data);
    }
}
