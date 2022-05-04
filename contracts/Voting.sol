pragma solidity ^0.4.21;

// BEFORE REQUIRE WAS A THING HEHE

contract Voting {
  /*************************************
   * Specify the duration of your vote *
   ************************************/
  uint256 private constant VOTE_DURATION = 2 minutes;
  uint256 private startTime_;
  string[] public candidates_;
  string public winner_;

  mapping(uint8 => uint256) public candidateTotals_;
  mapping(uint8 => string) private candidateIds_; // so we can get strings

  /*******************************************
   * Create an event for when a vote is cast *
   ******************************************/

  event VoteStillActive(uint256 remainingTime);
  event VoteComplete(string winner);
  event VoteCast(address voter, string votedFor);

  constructor() public {
    startTime_ = block.timestamp;

    // Hardcoded candidates
    candidates_.push("Adam");
    candidateIds_[0] = "Adam";

    /************************
     * Add other candidates *
     ***********************/

  }

  // Cast your vote
  function castVote(uint8 _candidate) external {
    if (block.timestamp <= startTime_ + VOTE_DURATION) {
      /**********************************
       * Increment the candidates total *
       *********************************/
        candidateTotals_[_candidate] += 1;

      /*********************************************
       * Emit an event that the vote has been cast *
       ********************************************/
       emit VoteCast(msg.sender, candidateIds_[_candidate])

    } else {
      emit VoteComplete(winner_);
    }
  }

  // Tally the vote and publicize the results
  function tallyVote() public {
    if (block.timestamp > startTime_ + VOTE_DURATION) {

      uint8 currentWinner;
      uint256 currentWinnerVotes = 0;

      /**********************************************
       * Find the winner, candidate with most votes *
       *********************************************/
        for (uint256 candidateIndex=0; candidateIndex <= candidates.length; candidateIndex++){
            if(candidateTotals_[candidates[candidateIndex]]>currentWinnerVotes){
                currentWinner = candidates[candidateIndex];
            }
        }





      /******************
       * Set the winner *
       *****************/

        emit VoteComplete(currentWinner)
      /**************************************************
       * Emit an event that the vote has been completed *
       *************************************************/


    // Vote duration has not elapsed
    } else {
      emit VoteStillActive((startTime_ + VOTE_DURATION) - block.timestamp);
    }
  }
}