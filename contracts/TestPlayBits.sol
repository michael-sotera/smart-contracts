// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SignatureMismatch();
error NonceAlreadyUsed();

contract TestPlayBits is ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    address private signer;

    mapping(uint256 => bool) public usedNonces;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name,
        string memory symbol,
        address _signer
    ) public initializer {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        signer = _signer;
    }

    function mint(
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) public onlyVerified(amount, nonce, signature) {
        usedNonces[nonce] = true;
        _mint(_msgSender(), amount);
    }

    function burn(
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) public onlyVerified(amount, nonce, signature) {
        usedNonces[nonce] = true;
        _burn(_msgSender(), amount);
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    modifier onlyVerified(
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) {
        if (usedNonces[nonce]) revert NonceAlreadyUsed();

        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(_msgSender(), amount, nonce))
        );
        if (ECDSA.recover(hash, signature) != signer) {
            revert SignatureMismatch();
        }
        _;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
