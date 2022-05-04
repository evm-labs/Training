pragma solidity 0.8.13;
// SPDX-License-Identifier: None


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract SampleOfALazyMintNFTContract is ERC721, Ownable, ReentrancyGuard {

    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using ECDSA for bytes32;

    constructor() ERC721("fReEmOnEyHere", "BLING"){
    }

    // variables related to Sale Status
    bool public SaleActive = false;
    bool public PreSaleActive = false;
    bool internal TeamMintAllowed = true;

    //variables related to the details of the collection
    uint256 public constant TOTALTOKENS = 1000;
    uint256 public constant PRESALETOKENS = 300;
    uint256 public constant TEAMTOKENS = 25;
    uint256 public constant UNITPRICE = 0.05 ether;
    uint256 public constant MAXPERTRANSACTION = 5;

    // util variables
    string public tokenBaseURI;
    string public unrevealedURI;
    Counters.Counter public tokenSupply;

    function changeSaleStatus() public onlyOwner{
        SaleActive = !SaleActive;
    }

    function changePreSaleStatus() public onlyOwner {
        PreSaleActive = !PreSaleActive;
    }

    function setTokenBaseURI(string memory _baseURI) external onlyOwner {
        tokenBaseURI = _baseURI;
    }

    function setUnrevealedURI(string memory _unrevealedUri) external onlyOwner {
        unrevealedURI = _unrevealedUri;
    }

    function verifyOwnerSignature(bytes32 hash, bytes memory signature)
        private
        view
        returns (bool)
    {
        return hash.toEthSignedMessageHash().recover(signature) == owner(); //.recover() is ECDSA based
    }

    function mint(uint8 _amount) external payable nonReentrant{
        require(SaleActive, "Sale is not yet active.");
        require(_amount <= MAXPERTRANSACTION, "Cannot purchase more than the maximum per transaction.");
        require(tokenSupply.current() + _amount <= TOTALTOKENS, "Would exceed the supply.");
        require(msg.value >=  _amount*UNITPRICE, "Amount not enough.");
        require(_amount > 1, "You must mint at least one token.");
        for (uint8 i=0; i <= _amount; i++){
            uint256 mintIndex = tokenSupply.current();
            _safeMint(msg.sender, mintIndex);
            tokenSupply.increment();
        }
    }

    function teamMint() external payable onlyOwner{
        require(tokenSupply.current() + TEAMTOKENS <= TOTALTOKENS, "Would exceed the supply.");
        require(TeamMintAllowed, "Team mint is not allowed anymore");
        for (uint256 i=0; i<=TEAMTOKENS; i++){
            uint256 mintIndex = tokenSupply.current();
            _safeMint(msg.sender, mintIndex);
            tokenSupply.increment();
        }
        TeamMintAllowed = false;
    }

    function presaleMint(uint256 _amount, bytes calldata _whitelistSignature)
        external
        payable
        nonReentrant
    {
        require(
            verifyOwnerSignature(
                keccak256(abi.encode(msg.sender)),
                _whitelistSignature
            ),
            "Invalid whitelist signature"
        );
        require(PreSaleActive, "Presale is not active");
        require(
            tokenSupply.current().add(_amount) <= PRESALETOKENS + TEAMTOKENS,
            "This purchase would exceed max supply of Presale"
        );
        for (uint256 i=0; i<=_amount; i++){
            uint256 mintIndex = tokenSupply.current();
            _safeMint(msg.sender, mintIndex);
            tokenSupply.increment();
        }
    }

    function withdraw(uint256 _amount) external payable onlyOwner{
        require(_amount <= address(this).balance, "Amount exceeds balance.");
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed.");
    }

    receive() external payable {}

    fallback() external payable {}
}