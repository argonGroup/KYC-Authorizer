/*
 * Address Classifier smart contract interface.
 * Copyright © 2018 by Argon Investments Management.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.4.20;

/**
 * Smart contract interface that is used to classify addresses.
 */
contract AddressClassifier {
  /**
   * Classify given address.
   *
   * @param _address address to be classified
   * @return class of given address
   */
  function classifyAddress (address _address) public view returns (uint256);
}
