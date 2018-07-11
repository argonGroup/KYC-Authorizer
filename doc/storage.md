# KYC Transfer Authorizer Smart Contract: Storage

This document describes storage structure of KYC Transfer Authorizer Smart Contract.

## 1. Fields

### 1.1. owner

##### Signature:

    address internal owner;

##### Description:

Address of the owner of smart contract.

##### Used in Use Cases:

* SetAddressClassifier

##### Modified in Use Cases:

* Deploy

### 1.2. addressClassifier

##### Signature:

    AddressClassifier internal addressClassifier;

##### Description:

Address classifier used by this smart contract.

##### Used in Use Cases:

* CheckAuthorization

##### Modified in Use Cases:

* Deploy
* SetAddressClassifier

### 1.3. unfreezeTimesZeroBalance

##### Signature:

    mapping (address => mapping (address => uint256))
    internal unfreezeTimesZeroBalance

##### Description:

Maps address of token smart contract to the mapping from address of token owner to corresponding unfreeze time.
Used only for addresses with zero balances.

##### Used in Use Cases:

* CheckAuthorization
* GetUnfreezeTime

##### Modified in Use Cases:

* CheckAuthorization
* SetUnfreezeTime

### 1.4. unfreezeTimesNonZeroBalance

##### Signature:

    mapping (address => mapping (address => uint256))
    internal unfreezeTimesNonZeroBalance

##### Description:

Maps address of token smart contract to the mapping from address of token owner to corresponding unfreeze time.
Used only for addresses with non-zero balances.

##### Used in Use Cases:

* CheckAuthorization
* GetUnfreezeTime

##### Modified in Use Cases:

* CheckAuthorization
* SetUnfreezeTime

### 1.5. authorizedAddresses

##### Signature:

    mapping (address => mapping (address => bool)) internal authorizedAddresses

##### Description:

Maps address to token smart contract to the mapping from address to the flags
telling whether the owner of this address is authorized to change unfreeze times
for the ownners of this token.

##### Used in Use Cases:

* SetUnfreezeTime
* IsAuthorizedAddress

##### Modified in Use Cases

* SetAuthorizedAddress

