pragma solidity ^0.4.18;

import "./Owned.sol";
import "./LinniaHub.sol";
import "./LinniaRecords.sol";

contract LinniaPermissions is Owned {
    event AccessGranted(address indexed patient, address indexed viewer,
        bytes32 fileHash);
    event AccessRevoked(address indexed patient, address indexed viewer,
        bytes32 fileHash);

    struct Permission {
        bool canAccess;
        // IPFS hash of the file, encrypted to the viewer
        bytes32 ipfsHash;
    }

    LinniaHub public hub;
    // filehash => viewer => permission mapping
    mapping(bytes32 => mapping(address => Permission)) public permissions;

    /* Modifiers */
    modifier onlyPatient(address user) {
        require(hub.rolesContract().roles(user) == LinniaRoles.Role.Patient);
        _;
    }

    /* Constructor */
    function LinniaPermissions(LinniaHub _hub, address initialAdmin)
        Owned(initialAdmin)
        public
    {
        hub = _hub;
    }

    /// Give a viewer access to a medical record owned by a patient
    /// @param fileHash the hash of the unencrypted file
    /// @param viewer the user being allowed to view the file
    /// @param ipfsHash the IPFS hash of the file encrypted to viewer
    function grantAccess(bytes32 fileHash, address viewer, bytes32 ipfsHash)
        onlyPatient(msg.sender)
        public
        returns (bool)
    {
        // assert the file hash exists and is indeed owned by patient
        require(hub.recordsContract().patientOf(fileHash) == msg.sender);
        // access must not have already been granted
        require(!permissions[fileHash][viewer].canAccess);
        permissions[fileHash][viewer] = Permission({
            canAccess: true,
            ipfsHash: ipfsHash
        });
        AccessGranted(msg.sender, viewer, fileHash);
        return true;
    }

    /// Revoke a viewer access to a document
    /// Note that this does not remove the file off IPFS
    /// @param fileHash the hash of the unencrytped file
    /// @param viewer the user being allowed to view the file
    function revokeAccess(bytes32 fileHash, address viewer)
        onlyPatient(msg.sender)
        public
        returns (bool)
    {
        require(hub.recordsContract().patientOf(fileHash) == msg.sender);
        // access must have already been grated
        require(permissions[fileHash][viewer].canAccess);
        permissions[fileHash][viewer] = Permission({
            canAccess: false,
            ipfsHash: 0
        });
        AccessRevoked(msg.sender, viewer, fileHash);
        return true;
    }
}