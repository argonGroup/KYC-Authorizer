# KYC Transfer Authorizer Smart Contract: Functional Requirements

This document describes functional requirements for KYC Transfer Authorizer smart contract.

## 0. Introduction

KYC Transfer Authorizer is an Ethereum smart contract that is used by EIP-20 compliant token smart contracts in order to authorize token transfers.
In the following sections describe authorization algorithm implemented by KYC Transfer Authorizer Smart Contract and its use cases.

## 1. Authorization Algorithm

This section describes authorization algorithm implemented by KYC Transfer Authorizer Smart Contract.

Token transfer is authorized based on the following values:

* Transfer origin address
* Transfer destination address
* Transfer amount
* Balance of transfer origin address

Transfer origin and destination addresses are classified using address classifier smart contract.
Then the following algorithm is executed:

    if (transfer origin address class is PWL)
      if (transfer destination address class is PWL, DWL, or SWL)
        authorize transfer
      else
        deny transfer
      end if
    else if (transfer origin address class is DWL)
      if (unfreeze time for the token is not yet reached)
        deny transfer
      else if (transfer destination address class is SWL)
        authorize transfer
      else if (transfer destination is PWL or DWL)
        if (transfer amount is the same as balance of transfer origin address)
          authorize transfer
        else
          deny transfer
      else
        deny transfer
      end if
    else if (transfer origin address class is SWL)
      if (transfer destination address class is PWL or SWL)
        authorize transfer
      else
        deny transfer
      end if
    else
      deny transfer
    end if

## 2. Use Cases

### 2.1. Deploy

**Actors:** _Administrator_, _Smart Contract_

**Goal:** _Administrator_ wants to deploy _Smart Contract_

##### Main Flow:

1. _Administrator_ deploys _Smart Contract_ providing the following information as constructor parameters: address of smart contract owner, address of address classifier smart contract
2. _Smart Contract_ remembers address of its owner
3. _Smart Contract_ remembers address of address classifier

### 2.2. SetAddressClassifier

**Actors:** _Administrator_, _Smart Contract_

**Goal:** _Administrator_ wants to change address of address classifier used by _Smart Contract_

##### Main Flow:

1. _Administracor_ calls method on _Smart Contract_ providing the following information as method parameters: address of new address classifier to be used by _Smart Contract_
2. _Administrator_ is an owner of _Smart Contract_
3. _Smart Contract_ remembers new address of address classifier

##### Exceptional Flow 1:

1. Same as in Main Flow
2. _Administrator_ is not an owner of _Smart Contract_
3. _Smart Contract_ cancels transaction

### 2.3. CheckAuthorization

**Actors:** _Token Contract_, _Smart Contract_

**Goal:** _Token Contract_ wants to authorize transfer of certain number of tokens from certain origin address to certain destination address

##### Main Flow:

1. _Token Contract_ calls constant method on _Smart Contract_ providing the following information as method parameters: _Token Contract_ address, origin address, destination address, transfer amount
2. Transfer should be authorized according to authorization algorithm described above
3. _Smart Contract_ returns authorization indicator to _Token Contract_

##### Exceptional Flow:

1. Same as in Main Flow
2. Transfer should be denied according to authorization alrogithm described above
3. _Smart Contract_ returns denial indicator to _Token Contract_

### 2.4. SetUnfreezeTime

**Actors:** _Administrator_, _Smart Contract_

**Goal:** _Administrator_ wants to set unfreeze time for certain token

##### Main Flow:

1. _Administracor_ calls method on _Smart Contract_ providing the following information as method parameters: address of token smart contract to set unfreeze time for, new unfreeze time for this token
2. _Administrator_ is an owner of _Smart Contract_
3. _Smart Contract_ sets unfreeze time for given token to given value

##### Exceptional Flow 1:

1. Same as in Main Flow
2. _Administrator_ is not an owner of _Smart Contract_
3. _Smart Contract_ cancels transaction
