// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AttendanceTracker {
    mapping(bytes32 => mapping(address => bool)) public attendance;

    /**
     * @notice Marks the attendance of a user for a specific event.
     * @param eventId The ID of the event for which attendance is being marked.
     * @dev The attendance is stored in a mapping where the event ID maps to a mapping of user addresses to attendance
     * status.
     */
    function markAttendance(bytes32 eventId) external {
        attendance[eventId][msg.sender] = true;
    }

    /**
     * @notice Checks the attendance status of a user for a specific event.
     * @param eventId The ID of the event for which attendance is being checked.
     * @param user The address of the user to check attendance for.
     * @dev The attendance status is retrieved from the mapping and returned.
     */
    function checkAttendance(bytes32 eventId, address user) external view returns (bool) {
        return attendance[eventId][user];
    }
}
