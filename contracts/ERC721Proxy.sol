// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



import "@openzeppelin/contracts-upgradeable/proxy/transparent/TransparentUpgradeableProxy.sol";




contract MyERC721Proxy is TransparentUpgradeableProxy {
    constructor(address _logic, address _admin, bytes memory _data) payable
        TransparentUpgradeableProxy(_logic, _admin, _data)
    {}

    function upgradeTo(address _newImplementation) external {
        _upgradeTo(_newImplementation);
    }

    function changeAdmin(address _newAdmin) external {
        _changeAdmin(_newAdmin);
    }

    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
}

