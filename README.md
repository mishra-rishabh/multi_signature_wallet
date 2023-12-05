# Multi Signature Wallet Smart Contract
## Overview
A multi-signature wallet is a cryptocurrency wallet that requires multiple signatures instead of just one to execute each transaction. The signatures are associated with different cryptographic private keys, while a defined threshold of keys must sign a transaction to validate it.

Multi-sig wallets are designed to minimize the chance that digital assets can be stolen using only a password or wallet key for access.

This Solidity smart contract allows multiple owners to control a wallet and requires a specified number of confirmations from owners before executing a transaction. Owners can submit transactions, confirm them, and execute them if the required confirmations are met.

## Features
- Multiple owners can be specified during contract initialization.
- Transactions can be submitted, requiring confirmations from the owners.
- Owners can confirm transactions, and once the required number of confirmations is reached, transactions can be executed.
- Each transaction includes the recipient address, amount, and execution status.

## Smart Contract Details
### Contract Structure
- `MultiSignatureWallet`: The main contract that implements the multi-signature wallet.

### Public Functions
1. **`Constructor()`**: Initializes the contract with a list of owners and the required number of confirmations.
2. **`submitTransaction()`**: Allows an owner to submit a new transaction, specifying the recipient address and amount.
3. **`confirmTransaction()`**: Owners can confirm a transaction, and if the required number of confirmations is reached, the transaction can be executed.
4. **`executeTransaction()`**: Executes a confirmed transaction, transferring the specified amount to the recipient.

**NOTE:** The `executeTransaction()` function is being internally called by `confirmTransaction()` function. Once the last confirmation is done the `executeTransaction()` will be called and amount will be transferred to the receiver's address.

### Events
1. **TransactionSubmitted**: Emitted when a new transaction is submitted, providing details such as the transaction ID, sender, receiver, and amount.
2. **TransactionConfirmed**: Emitted when an owner confirms a transaction.
3. **TransactionExecuted**: Emitted when a confirmed transaction is successfully executed.
