//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Error {
    error SequencerDown();
    error GracePeriodNotOver();
    error NotValidAddress();
    error UnValidAmount();
    error UnVolidpoolFee();
    error UnValidInput();
    error Empty();
}