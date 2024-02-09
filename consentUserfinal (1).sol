// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./consentOwnerfinal.sol";

contract ConsentUser {
    ConsentOwner public ownerContract;

    constructor(address _ownerContractAddress) {
        ownerContract = ConsentOwner(_ownerContractAddress);
    }

    function isActionAllowed(
        ConsentOwner.Role role,
        bytes32 purpose,
        uint256 dataID // New parameter
    ) public view returns (bool, string memory, bytes32) {
        require(ownerContract.getConsentCount() > 0, "No consents available");

        for (uint256 consentID = 0; consentID < ownerContract.getConsentCount(); consentID++) {
            ConsentOwner.ConsentInfo memory consent = ownerContract.getConsentInfo(consentID);

            if (consent.role != role || consent.dataID != dataID) {
                continue;
            }

            if ((consent.allowedPurpose & purpose) == 0 || (consent.restrictedPurpose & purpose) != 0) {
                continue;
            }

            return (true, consent.ipfsHash, consent.ownerPublicKey);
        }

        return (false, "", bytes32(0));
    }
}
