pragma solidity >=0.4.16 <0.8.0;


contract DAO {
    
   struct Proposal{
       uint id;
       string name;
       uint amount;
       address payable recipient;
       uint vote;
       uint end;
       bool exexcuted;
   } 
   
   mapping(address=> bool) public investors;
   mapping(address=>uint) public shares;
   mapping (address=>mapping(uint=>bool)) public votes;
   mapping(uint=>Proposal) public proposals;
   
   uint public totalShares;
   uint public avaliableFunds;
   uint public contributionEnd;
   uint public nextProposalId=1;
   uint public voteTime;
   uint public quorum;
   address public admin;
   
   constructor (uint _contributionTime,uint _voteTime,uint _quorum) public {
       contributionEnd=block.timestamp+_contributionTime;
       voteTime=_voteTime;
       quorum=_quorum;
       admin=msg.sender;
   }
   
   function contribute()payable external {
       require(block.timestamp<contributionEnd,'cannot contribute after contributionEnd');
       
       investors[msg.sender]=true;
       shares[msg.sender]+=msg.value;
       totalShares+=msg.value;
       avaliableFunds+=msg.value;
   }
   
   
   function redeemShare(uint amount) external{
       require(shares[msg.sender]>=amount,'not enough shares');
       require(avaliableFunds>=amount,'not enough available funds');
       
       shares[msg.sender]-=amount;
       avaliableFunds-=amount;
       msg.sender.transfer(amount);
   }
   
   function transferShare(uint amount,address to)external{
       require(shares[msg.sender]>=amount,'not enough shares');
       shares[msg.sender]-=amount;
       shares[to]+=amount;
       investors[to]=true;
   }
   
   function createProposal(string memory _name,uint amount,address payable _recipient) public onlyInvestors{
       require(avaliableFunds>=amount,'amount too big');
       proposals[nextProposalId]=Proposal(
           nextProposalId,
           _name,
           amount,
           _recipient,
           0,
           block.timestamp+voteTime,
           false
           );
           avaliableFunds-=amount;
           nextProposalId++;
   }
   
   function vote(uint proposalId) external onlyInvestors{
       Proposal storage proposal=proposals[proposalId];
       require(votes[msg.sender][proposalId]==false,'investor can only vote once for a proposal');
       require(block.timestamp < proposal.end,'can only vote until proposal end date');
       
       votes[msg.sender][proposalId]=true;
       proposal.vote+=shares[msg.sender];
   }
   
   function executeProposal(uint proposalId) external onlyAdmin{
       Proposal storage proposal=proposals[proposalId];
       require(block.timestamp >= proposal.end,'cannot execute proposal before end date');
       require(proposal.exexcuted==false,'cannot execute proposal already executed');
       require( ((proposal.vote * 100) / totalShares) >=quorum,'cannot execute proposal with votes below quorum');
       _transferEthers(proposal.amount,proposal.recipient);
       
   }
   
   function _transferEthers(uint amount,address payable to)internal{
       require(amount<=avaliableFunds,'not enough availableFunds');
       
       avaliableFunds-=amount;
       to.transfer(amount);
   }
   
   function withdrawEther(uint amount,address payable to)external onlyAdmin{
       _transferEthers(amount,to);
   }
   
   
   //fallback function
//    fallback()  external{
//       // avaliableFunds+=msg.value;
//    }
   
//    receive() payable external{
//        avaliableFunds+=msg.value;
//    }
   
  
   
   modifier onlyInvestors(){
       require(investors[msg.sender]==true,'only investors');
       _;
   }
   
   
   modifier onlyAdmin(){
       require(msg.sender==admin,'only admin');
       _;
   }
   
   
   
    
}