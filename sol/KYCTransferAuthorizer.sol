/*
 * KYC Transfer Authorizer Smart Contract.
 * Copyright © 2018 by ABDK Consulting.
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
   * Time period token arrived to reg D while list are frozen for.
   */
  uint256 internal constant FREEZE_PERIOD = 1 years;

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
      if (toClass == DWL_CLASS) {
        if (_token.balanceOf (_to) > 0) return false;
        else {
          if (_value > 0)
            autoSetUnfreezeTime (_token, _to);
          return true;
        }
      } else return toClass == PWL_CLASS || toClass == SWL_CLASS;
    } else if (fromClass == DWL_CLASS) {
      if (getUnfreezeTime (_token, _from) > currentTime ()) return false;
      else if (toClass == SWL_CLASS) {
        if (_value > 0 && _token.balanceOf (_from) == _value)
          autoResetUnfreezeTime (_token, _from);
        return true;
      } else if (_token.balanceOf (_from) != _value) return false;
      else if (toClass == PWL_CLASS) {
        if (_value > 0)
          autoResetUnfreezeTime (_token, _from);
        return true;
      } else if (toClass == DWL_CLASS) {
        if (_token.balanceOf (_to) > 0) return false;
        else {
          if (_value > 0) {
            autoResetUnfreezeTime (_token, _from);
            autoSetUnfreezeTime (_token, _to);
          }
          return true;
        }
      } else return false;
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
   * Set unfreeze time for given owner of given token.
   *
   * @param _token token to set unfreeze time for the owner of
   * @param _owner token owner to set unfreeze time for
   * @param _unfreezeTime unfreeze time for given token
   */
  function setUnfreezeTime (Token _token, address _owner, uint256 _unfreezeTime)
    public {
    if (msg.sender != owner) {
      require (authorizedAddresses [_token][msg.sender]);
      require (_token.balanceOf (_owner) == 0);
      require (addressClassifier.classifyAddress (_owner) == DWL_CLASS);
      require (_unfreezeTime > getUnfreezeTime (_token, _owner));
    }

    if (_token.balanceOf (_owner) == 0) {
      unfreezeTimesZeroBalance [_token][_owner] = _unfreezeTime;
      unfreezeTimesNonZeroBalance [_token][_owner] = 0;
    } else {
      unfreezeTimesZeroBalance [_token][_owner] = 0;
      unfreezeTimesNonZeroBalance [_token][_owner] = _unfreezeTime;
    }
  }

  /**
   * Get unfreeze time for given owner of given token.
   *
   * @param _token token to get unfreeze time for the owner of
   * @param _owner token owner to get unfreeze time for
   * @return unfreeze time for given owner of given token
   */
  function getUnfreezeTime (Token _token, address _owner)
  public view returns (uint256) {
    return _token.balanceOf (_owner) == 0 ?
      unfreezeTimesZeroBalance [_token][_owner] :
        unfreezeTimesNonZeroBalance [_token][_owner];
  }

  /**
   * Set authorization of the owner of given address to set unfreeze times for
   * the owners of given token.
   *
   * @param _token token to set authorization to change unfreeze times for the
   *        owners of
   * @param _address address to set authorization for the owner of
   * @param _authorized true to authorize, false to revoke authorization
   */
  function setAuthorizedAddress (
    Token _token, address _address, bool _authorized)
  public {
    require (msg.sender == owner);

    authorizedAddresses [_token][_address] = _authorized;
  }

  /**
   * Tell whether owner of given address is authorized to set unfreeze times for
   * the owners of given token.
   *
   * @param _token token to get authorization to change unfreeze times for the
   *        owners of
   * @param _address address to get authorization of
   */
  function isAuthorizedAddress (Token _token, address _address)
  public view returns (bool) {
    return authorizedAddresses [_token][_address];
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
   * Automatically set unfreeze time for given owner of given token.
   *
   * @param _token token to automatically set unfreeze time for the owner of
   * @param _owner token owner to automatically set unfreeze time for
   */
  function autoSetUnfreezeTime (Token _token, address _owner) internal {
    assert (_token.balanceOf (_owner) == 0);

    uint256 toUnfreezeTime = unfreezeTimesZeroBalance [_token][_owner];

    if (toUnfreezeTime == 0)
      unfreezeTimesNonZeroBalance [_token][_owner] =
        currentTime () + FREEZE_PERIOD;
    else
      unfreezeTimesNonZeroBalance [_token][_owner] = toUnfreezeTime;
  }

  /**
   * Automatically reset unfreeze time for given owner of given token.
   *
   * @param _token token to automatically reset unfreeze time for the owner of
   * @param _owner token owner to automatically reset unfreeze time for
   */
  function autoResetUnfreezeTime (Token _token, address _owner) internal {
    assert (_token.balanceOf (_owner) > 0);

    unfreezeTimesZeroBalance [_token][_owner] = 0;
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
   * Maps address of token smart contract to mapping from address of token
   * holder to corresponding unfreeze time.  Used only for addresses with zero
   * balances.
   */
  mapping (address => mapping (address => uint256)) internal
  unfreezeTimesZeroBalance;

  /**
   * Maps address of token smart contract to mapping from address of token
   * holder to corresponding unfreeze time.  Used only for addresses with
   * non-zero balances.
   */
  mapping (address => mapping (address => uint256)) internal
  unfreezeTimesNonZeroBalance;

  /**
   * Maps address of token smart contract to mapping from address of user to
   * boolean flag telling whether this user is authorized to set unfreeze times
   * for the owners of this token.
   */
  mapping (address => mapping (address => bool)) internal authorizedAddresses;
}
