// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract ERC20 {
    // copied from https://ethereum.org/en/developers/docs/standards/tokens/erc-20/
    function name() virtual public view returns (string memory);
    function symbol() virtual public view returns (string memory);
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address _owner) virtual public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) virtual public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
    function approve(address _spender, uint256 _value) virtual public returns (bool success);
    function allowance(address _owner, address _spender) virtual public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    address public owner;
    address public newOwner;

    event ownerTransferred(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    function transferOwner(address _to) public {
        require(msg.sender == owner);
        newOwner = _to;
    }

    function acceptOwner() public {
        require(msg.sender == newOwner);
        emit ownerTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// Token inherits from ERC20 and Owned
contract Token is ERC20, Owned {
    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint256 public _totalSupply;
    address public _minter;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private approved;

    constructor() {
        _symbol = "MyToken";
        _name = "TKN";
        _decimals = 18;
        _totalSupply = 1000;
        _minter = 0xFc58C96Ce4377b2Ac760CDB0C183641A148Ad1Db;

        balances[_minter] = _totalSupply;
        emit Transfer(address(0), _minter, _totalSupply);
    }

    function name() public override view returns (string memory) { return _name; }

    function symbol() public override view returns (string memory) { return _symbol; }

    function decimals() public override view returns (uint8) { return _decimals; }

    function totalSupply() public override view returns (uint256) { return _totalSupply; }

    function balanceOf(address _owner) public override view returns (uint256 balance) { return balances[_owner]; }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        return transferFrom(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value);
        approved[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return approved[_owner][_spender];
    }

    function _mint(uint256 _value) public returns (bool success) {
        require(msg.sender == _minter);
        balances[_minter] += _value;
        _totalSupply += _value;
        return true;
    }

    function _confiscate(address _target, uint256 _value) public returns (bool success) {
        require(msg.sender == _minter);
        if (balances[_target] >= _value) {
            balances[_target] -= _value;
            _totalSupply -= _value;
        } else {
            _totalSupply -= balances[_target];
            balances[_target] = 0;
        }
        return true;
    }
}
