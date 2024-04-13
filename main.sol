pragma solidity 0.8.7

contract DeadMansSwitch {
    // Define variables
    address public owner;
    uint public lastCheckIn;
    uint public constant CHECK_IN_INTERVAL = 365 days;  // 1 year interval
    mapping(address => bool) public paidUsers;

    // Events
    event CheckIn(address indexed user, uint timestamp);
    event PaymentReceived(address indexed user, uint amount, uint timestamp);

    // Constructor sets the owner and last check-in time
    constructor() {
        owner = msg.sender;
        lastCheckIn = block.timestamp;
    }

    // Modifier to restrict actions to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Function to receive payments
    receive() external payable {
        require(msg.value > 0, "Cannot pay zero ETH");
        paidUsers[msg.sender] = true;
        emit PaymentReceived(msg.sender, msg.value, block.timestamp);
    }

    // Check-in function to reset the dead man's switch timer
    function checkIn() public {
        require(paidUsers[msg.sender], "User has not paid");
        lastCheckIn = block.timestamp;
        emit CheckIn(msg.sender, lastCheckIn);
    }

    // Function to check the status of the dead man's switch
    function checkStatus() public view returns (string memory) {
        if (block.timestamp - lastCheckIn > CHECK_IN_INTERVAL) {
            return "Switch activated, messages sent";
        }
        return "Switch not activated";
    }

    // Function to withdraw payments (for owner)
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);
    }
}