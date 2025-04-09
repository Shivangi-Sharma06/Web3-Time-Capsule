// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TimeCapsule
{
    struct Capsule{
        uint unlockTime;
        address creator;
        address receiver;
        bool isLocked;
        string message;
        string ipfsHash;
    }

    uint capsuleCounter; //capsule kitne bane ye dekhega and then unhe ek id dega

    mapping(uint => Capsule) public capsules;

    mapping (address => uint[]) public userCapsule; //jisne capsule banaya uske address ke saath uska capsuleID bhi save karlo

    event capsuleCreated (uint capsuleID, address creator, address receiver);

    function createCapsule(address _receiver,string memory _ipfsHash, uint _unlockTime) public{
        require(_unlockTime > block.timestamp, "Can Only Be Unlock In The Future");
        Capsule memory newCapsule=Capsule({
            creator:msg.sender,
            receiver:_receiver,
            ipfsHash:_ipfsHash,
            unlockTime:_unlockTime,
            isLocked: true,
            message:""
        });

        capsules[capsuleCounter]=newCapsule;
        userCapsule[msg.sender].push(capsuleCounter);
        emit capsuleCreated(capsuleCounter, msg.sender,_receiver);
        capsuleCounter++;
    }

    event messageUpdated(uint capsuleID, string newMessage);

    function setMessage(uint capsuleID, string memory newMessage) public{
        require(msg.sender==capsules[capsuleID].creator, "Only Creator Of A Capsule Can Update A Message");
        capsules[capsuleID].message= newMessage;
        emit messageUpdated(capsuleID,newMessage);
    }

    event capsuleUnlocked(uint _capsuleID);

    function unlockCapsule(uint _capsuleID) public{
        Capsule storage current = capsules[_capsuleID];
        require(block.timestamp >= current.unlockTime, "Still Time Is Left");
        require(msg.sender==current.receiver, "Not The Intended Receiver");
        require(current.isLocked == true, "Capsule already unlocked");
        current.isLocked = false; // Unlocking the capsule
        emit capsuleUnlocked(_capsuleID);
    }

    event messageViewed(uint _capsuleID);

    function viewMessage(uint _capsuleID) public view returns(string memory){
        Capsule memory current = capsules[_capsuleID];
        require(block.timestamp >= current.unlockTime, "Cannot Be Viewed Before Time");
        require(msg.sender==current.receiver, "Not The Intended Receiver");
        require(current.isLocked==false, "Capsule Is Still Locked");
        return current.message;
    }

    function viewIpfsHash(uint _capsuleID) public view returns(string memory){
        Capsule memory current = capsules[_capsuleID];
        require(block.timestamp >= current.unlockTime, "Cannot Be Viewed Before Time");
        require(msg.sender==current.receiver, "Not The Intended Receiver");
        require(current.isLocked==false, "Capsule Is Still Locked");
        return current.ipfsHash;
    }

}