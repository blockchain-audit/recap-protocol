//SPDX-License-Identefier: MIT
pragma solidity ^0.8.24;

library errors {
    error SequencerDown();
    error GracePeriodNotOver();
    error UnvalidAddress();
    error UnvalidAmount();
    error UnvalidPoolfee();
    error UnvalidInput();
    error CanNotBeEmoty();
    error NotaPoolBalance();
}