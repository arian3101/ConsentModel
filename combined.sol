// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsentContract {
    enum Role {Nurse, Physician, Doctor, Pharmacist, InsuranceAgent, Researcher }

    struct ConsentInfo {
        uint256 dataID; // New parameter
        Role role;
        bytes32 allowedPurpose;
        bytes32 restrictedPurpose;
        string ipfsHash;
        bytes32 ownerPublicKey;
    }

    mapping(uint256 => ConsentInfo) private consentData;
    uint256 private consentIDCounter;

    event ConsentGranted(uint256 indexed consentID);

    function grantConsent(
        uint256 dataID, // New parameter
        Role role,
        bytes32 allowedPurpose,
        bytes32 restrictedPurpose,
        string memory ipfsHash,
        bytes32 ownerPublicKey
    ) public {
        uint256 consentID = consentIDCounter++;

        consentData[consentID] = ConsentInfo({
            dataID: dataID,
            role: role,
            allowedPurpose: allowedPurpose,
            restrictedPurpose: restrictedPurpose,
            ipfsHash: ipfsHash,
            ownerPublicKey: ownerPublicKey
        });

        emit ConsentGranted(consentID);
    }

    function getConsentInfo(uint256 consentID) public view returns (ConsentInfo memory) {
        return consentData[consentID];
    }

    function isConsentGiven(uint256 consentID) public view returns (bool) {
        return consentID < consentIDCounter;
    }

    function getConsentCount() public view returns (uint256) {
        return consentIDCounter;
    }

    function revokeConsent(uint256 consentID) public {
        require(isConsentGiven(consentID), "Consent not found");
        delete consentData[consentID];
    }

    function isActionAllowed(
        Role role,
        bytes32 purpose,
        uint256 dataID // New parameter
    ) public view returns (bool, string memory, bytes32) {
        require(getConsentCount() > 0, "No consents available");

        for (uint256 consentID = 0; consentID < getConsentCount(); consentID++) {
            ConsentInfo memory consent = getConsentInfo(consentID);

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
