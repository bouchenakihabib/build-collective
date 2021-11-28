pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract BuildCollective is Ownable {
  struct User {
    string username;
    uint256 balance;
    bool registered;
  }
  struct Entreprise {
    User owner;
    string name;
    uint256 balance;
    bool registered;
    User[] members;
  }

  struct Project {
    User userOwner;
    Entreprise entrepriseOwner;
    string name;
    uint256 balance;
    User[] contributors;
    string link;
    bool registered;
  }

  struct Bounty {
    string bugName;
    uint256 reward;
    bool isFixed;
  }
  
  mapping(address => Entreprise) private entreprises;
  mapping(address => User) private users;
  mapping(address => Project) private projects;
  mapping(address => Bounty) private bounties;
  mapping(address => bool) private isContributor;

  event EntrepriseSignedUp(address indexed userAddress, Entreprise indexed entreprise);
  event ProjectCreated(address indexed userAddress, Project indexed project);
  event BountyCreated(address indexed userAddress, Bounty indexed bounty);
  event UserSignedUp(address indexed userAddress, User indexed user);
  
  function user(address userAddress) public view returns (User memory) {
    return users[userAddress];
  }

  function entreprise(address entrepriseAddress) public view returns(Entreprise memory) {
    return entreprises[entrepriseAddress];
  } 

  function project (address projectAddress) public view returns (Project memory) {
    return projects[projectAddress];
  }

  function bounty (address bountyAddress) public view returns (Bounty memory) {
    return bounties[bountyAddress];
  }

  function signUp(string memory username) public returns (User memory) {
    require(bytes(username).length > 0,"username required");
    users[msg.sender] = User(username, 0, true);
    emit UserSignedUp(msg.sender, users[msg.sender]);
  }

  function addEntreprise(string memory entName) public returns (Entreprise memory) {
    entreprises[msg.sender].owner = users[msg.sender];
    entreprises[msg.sender].name = entName;
    entreprises[msg.sender].balance = 0;
    entreprises[msg.sender].registered = true;
    emit EntrepriseSignedUp(msg.sender, entreprises[msg.sender]);
  }

  function createProject(string memory projName, string memory projLink) public returns (Project memory){
    projects[msg.sender].userOwner = users[msg.sender];
    projects[msg.sender].entrepriseOwner = entreprises[msg.sender];
    projects[msg.sender].name = projName;
    projects[msg.sender].balance = 0;
    projects[msg.sender].link = projLink;
    projects[msg.sender].registered = true;
    emit ProjectCreated(msg.sender, projects[msg.sender]);
  }

  function createBounty(uint256 bountyReward, string memory name) public payable returns (Bounty memory) {
    require(msg.value > 0,"not enough eth to create bounty");
    bounties[msg.sender].bugName = name;
    bounties[msg.sender].reward = bountyReward;
    bounties[msg.sender].isFixed = false;
    emit BountyCreated(msg.sender, bounties[msg.sender]);
  }

  function addBalance(uint256 amount) public returns (bool) {
    require(users[msg.sender].registered, "unregistered user");
    users[msg.sender].balance += amount;
    return true;
  }
  function addBalanceEntreprise(uint256 amount) public returns (bool) {
    require(entreprises[msg.sender].registered, "unregistered entreprise");
    entreprises[msg.sender].balance += amount;
    return true;
  }

  function addBalanceProject(uint256 amount) public returns (bool){
    projects[msg.sender].balance += amount;
    return true;
  }

  function sendMoney(uint256 money, address[] memory contr) public {
    for(uint256 i = 0; i < contr.length; i++)
    {
      require(isContributor[contr[i]],"contributor does not exist");
      users[contr[i]].balance += money;
    }
  }

  function pushFix (address bountyAddr) public payable returns (bool) {
    require(bounties[bountyAddr].isFixed == false, "bug already fixed");
    bounties[bountyAddr].isFixed = true;
    users[msg.sender].balance += bounties[bountyAddr].reward;
    return true;
  }

  function getAllUserEntreprises() public view returns (Entreprise memory) {
    return entreprises[msg.sender];
  }

  function getAllUserProjects() public view returns(Project memory) {
    return projects[msg.sender];
  }

  function addEntrepriseMember(address member) public returns (bool) {
    require(entreprises[msg.sender].registered, "unregistered entreprise");
    entreprises[msg.sender].members.push(users[member]);
    return true;
  }

  function addProjectContributor(address contributor) public returns(bool) {
    projects[msg.sender].contributors.push(users[contributor]);
    return true;
  }
}
