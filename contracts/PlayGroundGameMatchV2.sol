// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SignatureMismatch();
error NonceAlreadyUsed();

contract PlaygroundGameMatchV2 is OwnableUpgradeable, UUPSUpgradeable {
    mapping(string => mapping(address => uint256)) public completedMatch; // completedMatch[gameId][msg.sender] = timestamp

    address private signer;
    mapping(uint256 => bool) public usedNonces;

    event MatchCompleted(address indexed _userAddress, string _gameId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function completeMatch(
        string calldata gameId,
        uint256 nonce,
        bytes calldata signature
    ) public onlyVerified(gameId, nonce, signature) {
        require(
            completedMatch[gameId][_msgSender()] == 0,
            "PlayGround GameMatch: match already completed"
        );

        completedMatch[gameId][_msgSender()] = block.timestamp;

        emit MatchCompleted(_msgSender(), gameId);
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    modifier onlyVerified(
        string calldata gameId,
        uint256 nonce,
        bytes calldata signature
    ) {
        if (usedNonces[nonce]) revert NonceAlreadyUsed();

        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(_msgSender(), gameId, nonce))
        );
        if (ECDSA.recover(hash, signature) != signer) {
            revert SignatureMismatch();
        }
        _;
    }
}
