pragma solidity ^0.4.23;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}

/**
    *** token recipient interface
*/
interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, bytes _extraData) external;
}
/*
    *This is TDH token
*/
contract TDHtoken
{
    using SafeMath for uint256;
    
    address owner; 
    bool public canBurn;
    bool public canApproveCall;
    uint8 public decimals = 6;
    uint256 public totalSupply = 100 * 1000000 * (10 ** uint256(decimals));
    string public name = "TronDappHub TDH";
    string public symbol = "TDH";

    mapping (address => uint256) balances;
    mapping (address => mapping(address => uint256)) allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _from, uint256 _value);

    constructor() public {
        owner = msg.sender;
        canBurn = false;
        canApproveCall = false;
        balances[owner] = totalSupply;
    }
    /**
        *** admin user can set Burn status flag variable in background.
    */
    function setCanBurn(bool _val) external {
        require(msg.sender == owner);
        require(_val != canBurn);
        canBurn = _val;
    }
    /**
        *** admin user can set approvecall status variable in background.
    */
    function setCanApproveCall(bool _val) external {
        require(msg.sender == owner);
        require(_val != canApproveCall);
        canApproveCall = _val;
    }
    /**
        *** this function will perform to change owner address of token by admin user.
    */
    function transferOwnership(address _newOwner) external {
        require(msg.sender == owner);
        require(_newOwner != address(0) && _newOwner != owner);
        owner = _newOwner;
    }
    /**
        *** the function to get token balance from given address
    */
    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }
    /**
        *** 
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        return _transfer(msg.sender, _to, _value);     
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require( _to != address(0) );
        require( balances[_from] >= _value );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) external returns (bool success) {
        require(canBurn == true);
        require(msg.sender != address(0));
        require(balances[msg.sender] >= _value && totalSupply > _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) external returns (bool success) {
        require(canApproveCall == true);
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, _extraData);
            return true;
        }
    }
}