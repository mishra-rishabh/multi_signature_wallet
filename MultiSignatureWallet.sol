// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 <= 0.9.0;

contract MultiSignatureWallet {
    // Public array to store addresses of owners
    address[] public owners;
    
    // Public variable to store the number of required confirmations for a transaction
    uint public requiredConfirmations;

    // Struct to represent a transaction
    struct Transaction {
        address toAddr;      // Recipient address
        uint value;          // Amount to be sent
        bool isExecuted;     // Flag to track if the transaction is executed
    }

    // Mapping to store whether an owner has confirmed a transaction
    mapping(uint => mapping(address => bool)) isConfirmed;

    // Array to store all transactions
    Transaction[] public transactions;

    // Event emitted when a new transaction is submitted
    event TransactionSubmitted(uint transactionId, address sender, address receiver, uint amount);

    // Event emitted when a transaction is confirmed by an owner
    event TransactionConfirmed(uint txnId);

    // Event emitted when a transaction is executed
    event TransactionExecuted(uint txnId);

    // Constructor function to initialize the contract with owners and required confirmations
    constructor(address[] memory _owners, uint _requiredConfirmations) {
        // Check if there are more than one owner
        require(_owners.length > 1, "Owners should be more than one!");
        
        // Check if the required confirmations are within a valid range
        require(_requiredConfirmations > 0 && _requiredConfirmations <= _owners.length, "Number of confirmations are not in sync with the number of owners!");

        for(uint i; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address!");
            owners.push(_owners[i]);
        }

        requiredConfirmations = _requiredConfirmations;
    }

    // Function to submit a new transaction
    function submitTransaction(address _to) public payable {
        // Check if the recipient address is valid
        require(_to != address(0), "Invalid receiver's address!");
        require(msg.value > 0, "Transfer amount must be greater than 0!");

        // Get the unique ID for the new transaction
        uint txnId = transactions.length;
        
        // Add the new transaction to the transactions array
        transactions.push(Transaction({toAddr: _to, value: msg.value, isExecuted: false}));

        // Emit an event indicating the submission of a new transaction
        emit TransactionSubmitted(txnId, msg.sender, _to, msg.value);
    }

    // Internal function to check if a transaction is confirmed
    function isTransactionConfirmed(uint _txnId) internal view returns (bool) {
        // Check if the transaction ID is valid
        require(_txnId < transactions.length, "Invalid transaction ID!");

        uint confirmationCount; // initially zero

        for(uint i; i < owners.length; i++) {
            // If an owner has confirmed the transaction, increment the confirmation count
            if(isConfirmed[_txnId][owners[i]]) {
                confirmationCount++;
            }
        }

        // Return true if the required confirmations are reached
        return confirmationCount >= requiredConfirmations;
    }

    // Function to execute a confirmed transaction
    function executeTransaction(uint _txnId) public payable {
        // Check if the transaction ID is valid
        require(_txnId < transactions.length, "Invalid transaction ID!");
        
        // Check if the transaction is not already executed
        require(!transactions[_txnId].isExecuted, "Transaction is already executed!");

        // Execute the transaction and check for success
        (bool isSuccess,) = transactions[_txnId].toAddr.call{value: transactions[_txnId].value}("");
        require(isSuccess, "Transaction failed!");
        
        // Mark the transaction as executed
        transactions[_txnId].isExecuted = true;
        
        // Emit an event indicating the execution of the transaction
        emit TransactionExecuted(_txnId);
    }

    // Function for an owner to confirm a transaction
    function confirmTransaction(uint _txnId) public {
        // Check if the transaction ID is valid
        require(_txnId < transactions.length, "Invalid transaction ID!");
        
        // Check if the owner has not already confirmed the transaction
        require(!isConfirmed[_txnId][msg.sender], "Transaction is already confirmed by the owner!");

        // Mark the owner's confirmation for the transaction
        isConfirmed[_txnId][msg.sender] = true;

        // Emit an event indicating the owner's confirmation
        emit TransactionConfirmed(_txnId);

        // If the transaction is confirmed by enough owners, execute it
        if(isTransactionConfirmed(_txnId)) {
            executeTransaction(_txnId);
        }
    }
}
