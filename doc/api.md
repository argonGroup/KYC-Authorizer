# KYC Transfer Authorizer Smart Contract: API

This document describes API of KYC Transfer Authorizer Smart Contract

## 1. Constructors

### 1.1. KYCTransferAuthorizer(address,AddressClassifier)

##### Signature:

    function KYCTransferAuthorizer (
      address _owner, AddressClassifier _addressClassifier)
    public

##### Description:

Create KYC Transfer Classifier Smart Contract, make owner of given `_owner` address to be the owner of smart contract, use given address classifier `_addressClassifier`.
May be called by anyone.
Does not accept ether.

##### Use Cases:

* Deploy

## 2. Methods

### 2.1. transferAuthorized(Token,address,address,uint256)

##### Signature:

    function transferAuthorized (
      Token _token, address _from, address _to, uint256 _value)
    public view returns (bool)

##### Description:

Check whether transfer of `_value` tokens manager by given token smart contract `_token` from given address `_from` to given address `_to` is authorized.
Return `true` if transfer is authorized, `false` otherwise.
May be called by anyone.
Does not accept ether.

##### Use Cases:

* CheckAuthorization

### 2.2. setAddressClassifier(AddressClassifier)

##### Signature:

    function setAddressClassifier (AddressClassifier _addressClassifier)
    public

##### Description:

Set given address classifier `_addressClassifier` to be used by smart contract.
May be called by the owner of smart contract only.
Does not accept ether.

##### Use Cases:

* SetAddressClassifier

### 2.3. setUnfreezeTime(Token,uint256)

##### Signature:

    function setUnfreezeTime (Token _token, uint256 _unfreezeTime) public

##### Description:

Set unfreeze time for given token `_token` to given time `_unfreezeTime`.

##### Use Cases:

* SetUnfreezeTime
