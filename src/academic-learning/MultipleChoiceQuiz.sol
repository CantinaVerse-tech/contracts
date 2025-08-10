// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultipleChoiceQuiz {
    struct Question {
        string question;
        string[] options;
        uint8 correctAnswer; // Index of correct option (0-based)
        string explanation;
    }

  string public quizTitle;
  Question[] public questions;
}
