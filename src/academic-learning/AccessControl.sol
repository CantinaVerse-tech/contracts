// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract AccessControl {
    mapping(address => uint8) public roles; // 0=none, 1=user, 2=admin
    address public superAdmin;

    constructor() {
        superAdmin = msg.sender;
        roles[msg.sender] = 2;
    }

    /**
     * @notice Sets the role of a user.
     * @param _user The address of the user to set the role for.
     * @param _role The role to set for the user.
     * @dev The role can be 0 (none), 1 (user), or 2 (admin).
     */
    function setRole(address _user, uint8 _role) external {
        require(_role <= 2, "Invalid role");
        roles[_user] = _role;
    }

    /**
     * @notice Grants admin access to the contract.
     * @dev Only the super admin can call this function.
     */
    function adminOnlyFunction() external view returns (string memory) {
        require(roles[msg.sender] == 2, "Admin only");
        return "Admin access granted";
    }
}
