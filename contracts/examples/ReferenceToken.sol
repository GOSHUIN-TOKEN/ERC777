/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this
* file, You can obtain one at http://mozilla.org/MPL/2.0/. */
pragma solidity 0.4.21;

/// @title ERC777 ReferenceToken Contract
/// @author Jordi Baylina, Jacques Dafflon
/// @dev This token contract's goal is to give an example implementation
///  of ERC777 with ERC20 compatiblity using the base ERC777 and ERC20
///  implementations provided with the erc777 package.
///  This contract does not define any standard, but can be taken as a reference
///  implementation in case of any ambiguity into the standard


import { ERC777ERC20BaseToken } from "../ERC777ERC20BaseToken.sol";
import { Ownable } from "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract ReferenceToken is ERC777ERC20BaseToken, Ownable {

    function ReferenceToken(
        string _name,
        string _symbol,
        uint256 _granularity
    ) public ERC777ERC20BaseToken(_name, _symbol, _granularity) { // solhint-disable-line no-empty-blocks
        // insert custom constructor code
    }

    /// @notice Disables the ERC20 interface. This function can only be called
    ///  by the owner.
    function disableERC20() public onlyOwner {
        mErc20compatible = false;
        setInterfaceImplementation("ERC20Token", 0x0);
    }

    /// @notice Re enables the ERC20 interface. This function can only be called
    ///  by the owner.
    function enableERC20() public onlyOwner {
        mErc20compatible = true;
        setInterfaceImplementation("ERC20Token", this);
    }

    /* -- Mint And Burn Functions (not part of the ERC777 standard, only the Events/tokensReceived call are) -- */
    //
    /// @notice Generates `_amount` tokens to be assigned to `_tokenHolder`
    ///  Sample mint function to showcase the use of the `Minted` event and the logic to notify the recipient.
    /// @param _tokenHolder The address that will be assigned the new tokens
    /// @param _amount The quantity of tokens generated
    /// @param _operatorData Data that will be passed to the recipient as a first transfer
    function mint(address _tokenHolder, uint256 _amount, bytes _operatorData) public onlyOwner {
        requireMultiple(_amount);
        mTotalSupply = mTotalSupply.add(_amount);
        mBalances[_tokenHolder] = mBalances[_tokenHolder].add(_amount);

        callRecipient(msg.sender, 0x0, _tokenHolder, _amount, "", _operatorData, true);

        Minted(msg.sender, _tokenHolder, _amount, _operatorData);
        if (mErc20compatible) { Transfer(0x0, _tokenHolder, _amount); }
    }

    /// @notice Burns `_amount` tokens from `_tokenHolder`
    ///  Sample burn function to showcase the use of the `Burned` event.
    /// @param _tokenHolder The address that will lose the tokens
    /// @param _amount The quantity of tokens to burn
    function burn(address _tokenHolder, uint256 _amount, bytes _userData, bytes _operatorData) public onlyOwner {
        requireMultiple(_amount);

        callSender(msg.sender, _tokenHolder, 0x0, _amount, _userData, _operatorData);

        require(balanceOf(_tokenHolder) >= _amount);

        mBalances[_tokenHolder] = mBalances[_tokenHolder].sub(_amount);
        mTotalSupply = mTotalSupply.sub(_amount);

        Burned(msg.sender, _tokenHolder, _amount, _userData, _operatorData);
        if (mErc20compatible) { Transfer(_tokenHolder, 0x0, _amount); }
    }
}
