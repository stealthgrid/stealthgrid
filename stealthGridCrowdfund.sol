pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract token { function transfer(address receiver, uint amount){  } }
contract StealthCrowdsale {
  using SafeMath for uint256;
  
  struct Funder {
        address addr;
        uint noOfToken;
   }
   
   Funder[] public funder;


  // uint256 durationInMinutes;
  // address where funds are collected
  address public wallet;
  // token address
  address public addressOfTokenUsedAsReward;
  token tokenReward;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTimeInMinutes;
  uint256 public endTimeinMinutes;
  //uint public fundingGoalinToken = 3000000000000000000000000;
  uint public fundingGoalinToken = 3000000;
  //uint256 public price = 1040; // 1ether = 1040usd as of Jan 19 2018
  uint256 public price = 107841; // for testting purposes
  // amount of raised money in wei
  uint256 public weiRaised;
  uint counterIndex = 0;
  uint accountCount;
  address public creator;
  bool public distributed = false;
  uint public tokenSold = 0;
  uint public tokenBonusForFirst = 3000000000000000000000000; //3million
  uint public tokenBonusForSecond = 5000000000000000000000000; //5million
  uint public tokenBonusForThird = 10000000000000000000000000; //10million
  uint public tokenBonusForFourth = 15000000000000000000000000; //15million
  uint public tokenBonusForFifth = 20000000000000000000000000; //20million
  uint public tokenBonusForSix = 25000000000000000000000000; //25million
  uint public tokenBonusForSeven = 30000000000000000000000000; //30million
  uint public tokenBonusForEight = 35000000000000000000000000; //35million
  uint public tokenBonusForNinth = 40000000000000000000000000; //40million
  uint public tokenBonusForTenth = 45000000000000000000000000; //45million
  uint public tokenBonusPercentageFirst = 50;
  uint public tokenBonusPercentageSecond = 45;
  uint public tokenBonusPercentageThird = 40;
  uint public tokenBonusPercentageFourth = 35;
  uint public tokenBonusPercentageFifth = 30;
  uint public tokenBonusPercentageSix = 25;
  uint public tokenBonusPercentageSeven = 20;
  uint public tokenBonusPercentageEight = 15;
  uint public tokenBonusPercentageNine = 10;
  uint public tokenBonusPercentageTen = 5;
  uint public miniumInvestement = 480455087058461740;// 500 usd
  bool public crowdsaleIsActive = true;
  
  
  mapping(address => uint256) public balanceOf;
  bool public crowdsaleClosed = false;
  bool public allocated = false;
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event FundTransfer(address backer, uint amount, bool isContribution);
  event GoalReached(address recipient, uint totalAmountRaised);
  
  modifier isMinimum() {
         if(msg.value < miniumInvestement) throw;
        _;
    }
    
  modifier afterDeadline() { 
      if (now <= endTimeinMinutes) throw;
      _;
  }    
  
  modifier isCreator(){
    require(msg.sender == creator) ;
    _;
  }

  function StealthCrowdsale(uint256 _startTimeInMinutes, 
  uint256 _endTimeInMinutes, 
  address _beneficiary, 
  address _addressTokenUsedAsReward) {
    creator = msg.sender;
    wallet = _beneficiary;
    // durationInMinutes = _durationInMinutes;
    addressOfTokenUsedAsReward = _addressTokenUsedAsReward;
    fundingGoalinToken = fundingGoalinToken * 1 ether;
    tokenReward = token(addressOfTokenUsedAsReward);
    //startTime = now + 28250 * 1 minutes;
    startTimeInMinutes = _startTimeInMinutes;
    endTimeinMinutes = _endTimeInMinutes;
    
    //endTime = startTime + 64*24*60 * 1 minutes;
  }

  // fallback function can be used to buy tokens
  function () payable isMinimum{
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
    uint tempTokenSold = tokenSold;
    bool flagFundingGoalinTokenIsReached = false;
    require(crowdsaleIsActive);
    require(beneficiary != 0x0);
    //require(validPurchase());
    //require(checkInvestor(beneficiary));

    uint256 weiAmount = msg.value;
    
    // calculate token amount to be sent
    uint256 tokens = (weiAmount) * (price / 50);
    tokenSold = tokenSold + tokens;
    if (tokenSold > fundingGoalinToken) {
        tokenSold =  tempTokenSold;
        flagFundingGoalinTokenIsReached = true;
    }
        
    require(!flagFundingGoalinTokenIsReached);
    
    //tokens = computeTokenBonus(tokens);
    // update state
    //balanceOf[msg.sender] += weiAmount;
    weiRaised = weiRaised.add(weiAmount);
    tokenReward.transfer(beneficiary, tokens);
    //newFunder(beneficiary,tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    wallet.send(weiAmount);
    
    //FundTransfer(wallet, weiAmount, false);
  }
  
  
  //compute token value
  function computeTokenBonus(uint256  _token) internal constant returns(uint){
      uint256 tokenBonus = _token;
      if(tokenSold < tokenBonusForFirst){ //token sold < 3 million 
        tokenBonus += (tokenBonus * tokenBonusPercentageFirst) / 100; //50 percent discount
      }else if(tokenSold < tokenBonusForSecond) {
        tokenBonus += (tokenBonus * tokenBonusPercentageSecond) / 100; //45 percent discount  
      }else if(tokenSold < tokenBonusForThird) {
        tokenBonus += (tokenBonus * tokenBonusPercentageThird) / 100; //40 percent discount  
      }else if(tokenSold < tokenBonusForFourth) {
        tokenBonus += (tokenBonus * tokenBonusPercentageFourth) / 100; //35 percent discount  
      }else if(tokenSold < tokenBonusForFifth) {
        tokenBonus += (tokenBonus * tokenBonusPercentageFifth) / 100; //30 percent discount  
      }else if(tokenSold < tokenBonusForSix) {
        tokenBonus += (tokenBonus * tokenBonusPercentageSix) / 100; //25 percent discount  
      }else if(tokenSold < tokenBonusForSeven) {
        tokenBonus += (tokenBonus * tokenBonusPercentageSeven) / 100; //20 percent discount  
      }else if(tokenSold < tokenBonusForEight) {
        tokenBonus += (tokenBonus * tokenBonusPercentageEight) / 100; //15 percent discount  
      }else if(tokenSold < tokenBonusForNinth) {
        tokenBonus += (tokenBonus * tokenBonusPercentageNine) / 100; //10 percent discount  
      }else if(tokenSold < tokenBonusForTenth) {
        tokenBonus += (tokenBonus * tokenBonusPercentageTen) / 100; //5 percent discount  
      }
      return tokenBonus;
  }
  
  //checking for investor 
  function checkInvestor(address _investorAddress) internal constant returns(bool){
      bool isInvestor = false;
      if(_investorAddress == 0x28eeB94287bd88BcAB6ef33BD43Ad94F22bd1119) { isInvestor = true;}
      if(_investorAddress == 0xdEdF194C84F8B632B5Ea60213D70bED5c366e073) { isInvestor = true;}
      if(_investorAddress == 0xdEdF194C84F8B632B5Ea60213D70bED5c366e073) { isInvestor = true;}
      if(_investorAddress == 0xdEdF194C84F8B632B5Ea60213D70bED5c366e073) { isInvestor = true;}
      if(_investorAddress == 0xa100FcDe37D0058804ae995C4DB53a021f643329) { isInvestor = true;}
      return isInvestor;
  }
  
  //add Funder to struct of array
  function newFunder(address _funderAddress, uint _noOfToken) internal  {
    Funder memory newFunder;
    newFunder.addr = _funderAddress;
    newFunder.noOfToken  = _noOfToken;
    funder.push(newFunder)-1;
  }
  
  //check if FundingGoal is GoalReached
  function fundingGoalisReached() public constant returns (bool) {
      bool isReached = false;
      require (hasEnded());
      if(tokenSold >= fundingGoalinToken) {
          isReached = true;
      }
      return isReached;
  }

  /* distribution of token after crowdsale
  function distributeToken() isCreator{
      require(now > endTimeinMinutes);
      require(!distributed);
      for(uint i=0;i<funder.length;i++)
      {
        Funder investor = funder[i];
        tokenReward.transfer(investor.addr, investor.noOfToken);
      }
      distributed = true;
  } */
  
  function finishedCrowdsale() isCreator {
      crowdsaleIsActive = false;
  }
  
  
  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTimeInMinutes && now <= endTimeinMinutes;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTimeinMinutes;
  }
 
}
