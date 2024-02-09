// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConsentOwner {
    enum Role {Pharmacist,Nurse,Doctor,Physician,Researcher,InsuranceAgent }

    struct ConsentInfo {
        uint256 dataID; // identity for the data shared
        Role role;
        bytes32 allowedPurpose;
        bytes32 restrictedPurpose; 
        string ipfsHash; //copied from pinata
        bytes32 ownerPublicKey; //used to decrypt the data file shared
    }

    mapping(uint256 => ConsentInfo) private consentData;
    uint256 private consentIDCounter;

    event ConsentGranted(uint256 indexed consentID);

    function grantConsent(
        uint256 dataID, 
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
}
