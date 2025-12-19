// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.26;

import './interfaces/IUniswapV2Pair.sol';
import './UniswapV2ERC20.sol';
import './libraries/Math.sol';
import './libraries/UQ112x112.sol';
import './interfaces/IERC20.sol';
import './interfaces/IUniswapV2Factory.sol';
import './interfaces/IUniswapV2Callee.sol';

contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    uint public constant override MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public immutable override factory;
    address public immutable override token0;
    address public immutable override token1;

    uint112 private reserve0;
    uint112 private reserve1;
    uint32  private blockTimestampLast;

    uint public override price0CumulativeLast;
    uint public override price1CumulativeLast;
    uint public override kLast;

    uint private unlocked = 1;
    modifier lock() {
        if (unlocked != 1) revert Locked();
        unlocked = 0;
        _;
        unlocked = 1;
    }

    error Locked();
    error Overflow();
    error InsufficientOutputAmount();
    error InsufficientLiquidity();
    error InsufficientInputAmount();
    error InvalidTo();
    error KInvariant();
    error TransferFailed();
    error Forbidden();

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external override {
        if (msg.sender != factory) revert Forbidden();
        // Immutable assignment – we can safely cast because we trust the factory
        assembly {
            sstore(token0.slot, _token0)
            sstore(token1.slot, _token1)
        }
    }

    // ... (rest of the contract remains exactly the same as the previous version)
