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

    if (transfer destination class is DWL and balance of destination address is non zero)
      deny transfer
    else if (transfer origin address class is PWL)
      if (transfer destination address class is PWL, DWL, or SWL)
        authorize transfer
      else
        deny transfer
      end if
    else if (transfer origin address class is DWL)
      if (unfreeze time for the token sender is not yet reached)
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

##### Main Flow 1:

1. _Token Contract_ calls constant method on _Smart Contract_ providing the following information as method parameters: _Token Contract_ address, origin address, destination address, transfer amount
2. Transfer should be authorized according to authorization algorithm described above
3. Origin address class is not DWL or transfer value is zero, or transfer value is less than origin balance
4. Destination address class is not in DWL or unfreeze date for destination address is already set or transfer value is zero
5. _Smart Contract_ returns authorization indicator to _Token Contract_

##### Main Flow 2:

1. Same as in Main Flow 1
2. Same as in Main Flow 1
3. Origin address is DWL, transfer value is not zero, and transfer value equals to origin balance
4. _Smart Contract_ resets unfreeze date for origin address
5. Same as step 4 in Main Flow
6. Same as step 5 in Main Flow

##### Main Flow 3:

1. Same as in Main Flow 1
2. Same as in Main Flow 1
3. Same as in Main Flow 1
4. Destination address class is DWL, and unfreeze date for destination address is not set, and transfer value is non-zero
5. _Smart Contract_ sets unfreeze date for destination address to 1 year ahead of current time, but this new unfreeze date will become effective only in case transfer will actually be performed
6. Same as step 5 of Main Flow 1

##### Main Flow 3:

1. Same as in Main Flow 1
2. Same as in Main Flow 1
3. Same as in Main Flow 2
4. Same as in Main Flow 2
5. Same as step 4 in Main Flow 3
6. Same as step 5 in Main Flow 3
7. Same as step 5 in Main Flow 1

##### Exceptional Flow 1:

1. Same as in Main Flow 1
2. Transfer should be denied according to authorization algorithm described above
3. _Smart Contract_ returns denial indicator to _Token Contract_

### 2.4. SetUnfreezeTime

**Actors:** _User_, _Smart Contract_

**Goal:** _User_ wants to set unfreeze time for certain owner of certain token

##### Main Flow 1:

1. _User_ calls method on _Smart Contract_ providing the following information as method parameters: address of token smart contract to set unfreeze time for the owner of, address of token owner to set unfreeze time for, new unfreeze time for this owner of this token
2. _User_ is an owner of _Smart Contract_
3. _Smart Contract_ sets unfreeze time for the given owner of given token to given value

##### Main Flow 2:

1. Same as in Main Flow 1
2. _User_ is not an owner of _Smart Contract_
3. _User_ is authorized to change unfreeze times for the owners of given token
4. Given token owner is in DWL
5. Given token owner has no tokens
6. Unfreeze time is not set for given token owner of given token, or current unfreeze time is less than given new unfreeze time
7. Same as step 3 of Main Flow 1

##### Exceptional Flow 1:

1. Same as in Main Flow 1
2. Same as in Main Flow 2
3. _User_ is not authorized to change unfreeze times for the owners of given token
4. _Smart Contract_ cancels transaction

##### Exceptional Flow 2:

1. Same as in Main Flow 1
2. Same as in Main Flow 2
3. Same as in Main Flow 2
4. Given token owner is not in DWL
5. _Smart Contract_ cancels transaction

##### Exceptional Flow 3:

1. Same as in Main Flow 1
2. Same as in Main Flow 2
3. Same as in Main Flow 2
4. Same as in Main Flow 2
5. Given token owner has some tokens
6. _Smart Contract_ cancels transaction

##### Exceptional Flow 4:

1. Same as in Main Flow 1
2. Same as in Main Flow 2
3. Same as in Main Flow 2
4. Same as in Main Flow 2
4. Same as in Main Flow 2
6. Unfreeze time for given owner of given token is set and is greater than or equal to given new unfreeze time
7. _Smart Contract_ cancels transaction

### 2.5. GetUnfreezeTime

**Actors:** _User_, _Smart Contract_

**Goal:** _User_ wants to know unfreeze time for certain owner of certain token

##### Main Flow:

1. _User_ calls constant method on _Smart Contract_ providing the following information as method parameters: address of token smart contract to get unfreeze time for the owner of, address of token owner to get unfreeze time for
2. _Smart Contract_ returns to _User_ unfreeze time for the given owner of given token

### 2.5. SetAuthorizedAddress

**Actors:** _Administrator_, _Smart Contract_

**Goal:** _Administrator wants to set whether owner of certain address is authorized to change unfreeze times for the owners of certain token

##### Main Flow:

1. _Administrator_ calls method on _Smart Contract_ providing the following information as method parameters: address of token smart contract to set authorization to change unfreeze times for the owners of, address to change authorization for the owner of, authorization flag
2. _Asministrator_ is an owner of _Smart Contract_
3. _Smart Contract_ sets whether owner of given address is authorized to change unfreeze times for the owners of given token

##### Exceptional Flow 1:

1. Same as in Main Flow
2. _Administrator_ is not an owner of _Smart Contract_
3. _Smart Contract_ cancels transaction

### 2.6. IsAuthorizedAddress

**Actors:** _User_, _Smart Contract_

**Goal:** _User_ wants to know whether owner of certain address is authorized to change unfreeze times for the owners of certain token

##### Main Flow:

1. _User_ calls constant method on _Smart Contract_ providing the following information as method parameters: address of token smart contract to get authorization flag for, address to get authorization flag for the owner of
2. _Smart Contact_ returns to _User_ authorization flag telling whether owner of given address is authorized to change unfreeze times for the owners of given token
 