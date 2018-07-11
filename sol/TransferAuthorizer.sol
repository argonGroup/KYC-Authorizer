/*
 * Transfer Authorizer smart contract interface.
 * Copyright © 2018 by Argon Investments Management
 * Author: Mikhail Vladimirov
 */
pragma solidity ^0.4.20;

import "./Token.sol";

/**
 * Smart contract interface that is used to authorize token transfers.
 */
contract TransferAuthorizer {
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
    public view returns (bool);
}
