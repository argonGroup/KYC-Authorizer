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

### 1.3. unfreezeTimes

##### Signature:

    mapping (address => uint256) internal unfreezeTimes

##### Description:

Maps address of token smart contract to corresponding unfreeze time.

##### Used in Use Cases:

* CheckAuthorization

##### Modified in Use Cases:

* SetUnfreezeTime
