/*
 * KYC Transfer Authorizer Smart Contract.
 * Copyright © 2018 by Argon Investments Management.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.4.20;

import "./TransferAuthorizer.sol";
import "./AddressClassifier.sol";

/**
 * Transfer authorizer that authorizes transfers based on address classification
 * performed by address classifier smart contract.
 */
contract KYCTransferAuthorizer is TransferAuthorizer {
  /**
   * Platform white list address class.
   */
  uint256 internal constant PWL_CLASS = 1;

  /**
   * Reg D white list address class.
   */
  uint256 internal constant DWL_CLASS = 2;

  /**
   * Reg S white list address class.
   */
  uint256 internal constant SWL_CLASS = 3;

  /**
   * Create new KYC transfer authorizer with given owner and address
   * classifier.
   *
   * @param _owner address of smart contract owner
   * @param _addressClassifier address of address classifier to use
   */
  function KYCTransferAuthorizer (
    address _owner,
    AddressClassifier _addressClassifier)
    public {
    owner = _owner;
    addressClassifier = _addressClassifier;
  }

  /**
   * Check authorization for given token transfer.
   *
   * @param _token token to be transferred
   * @param _from address tokens to be transferred from
   * @param _to address tokens to be transferred to
   * @param _value number of tokens to be transferred
   * @return true if transfer is authorized, false otherwise
   */
  function transferAuthorized (
    Token _token, address _from, address _to, uint256 _value)
    public view returns (bool) {
    uint256 fromClass = addressClassifier.classifyAddress (_from);
    uint256 toClass = addressClassifier.classifyAddress (_to);

    if (fromClass == PWL_CLASS) {
      return toClass == PWL_CLASS ||
             toClass == DWL_CLASS ||
             toClass == SWL_CLASS;
    } else if (fromClass == DWL_CLASS) {
      if (unfreezeTimes [_token] > currentTime ()) return false;
      else if (toClass == SWL_CLASS) return true;
      else if (toClass == PWL_CLASS || toClass == DWL_CLASS)
        return _token.balanceOf (_from) == _value;
      else return false;
    } else if (fromClass == SWL_CLASS) {
      return toClass == PWL_CLASS || toClass == SWL_CLASS;
    } else return false;
  }

  /**
   * Set new address classifier to be used by this smart contract.
   *
   * @param _addressClassifier new address classifier to be used by this smart
   *        contract
   */
  function setAddressClassifier (AddressClassifier _addressClassifier)
    public {
    require (msg.sender == owner);

    addressClassifier = _addressClassifier;
  }

  /**
   * Set unfreeze time for given token.
   *
   * @param _token token to set unfreeze time for.
   * @param _unfreezeTime unfreeze time for given token
   */
  function setUnfreezeTime (Token _token, uint256 _unfreezeTime) public {
    require (msg.sender == owner);

    unfreezeTimes [_token] = _unfreezeTime;
  }

  /**
   * Get current time.
   *
   * @return current time
   */
  function currentTime () internal view returns (uint256) {
    return block.timestamp;
  }

  /**
   * Address of the owner of this smart contract.
   */
  address internal owner;

  /**
   * Address classifier used by this smart contract.
   */
  AddressClassifier internal addressClassifier;

  /**
   * Maps address of token smart contract to corresponding unfreeze time.
   */
  mapping (address => uint256) internal unfreezeTimes;
}
