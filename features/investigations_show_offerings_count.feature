Feature: Investigations show the offerings count
  So I can see how many times an investigation has been assigned
  As a teacher
  I want to see the offerings count

  Background:
    Given The default project and jnlp resources exist using factories
    Given the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And I login with username: teacher password: teacher

  @selenium
  Scenario: The investigations list can show the offerings count
    Given the following empty investigations exist:
      | name       | user      | offerings_count | created_at                      | publication_status  |
      | NewestInv  | teacher   | 5               | Wed Jan 26 12:00:00 -0500 2011  | published           |
      | MediumInv  | teacher   | 10              | Wed Jan 23 12:00:00 -0500 2011  | published           |
      | OldestInv  | teacher   | 20              | Wed Jan 20 12:00:00 -0500 2011  | published           |
    When I show offerings count on the investigations page
    Then I should see "assigned 5 times"
    And I should see "assigned 10 times"
    And I should see "assigned 20 times"

  @selenium
  Scenario: The investigations list offering count shows on all pages
    Given the following empty investigations exist:
      | name | user    | offerings_count | created_at                     | publication_status |
      | 1    | teacher | 5               | Wed Jan 01 12:00:00 -0500 2011 | published          |
      | 2    | teacher | 10              | Wed Jan 02 12:00:00 -0500 2011 | published          |
      | 3    | teacher | 20              | Wed Jan 03 12:00:00 -0500 2011 | published          |
      | 4    | teacher | 5               | Wed Jan 07 12:00:00 -0500 2011 | published          |
      | 5    | teacher | 10              | Wed Jan 06 12:00:00 -0500 2011 | published          |
      | 6    | teacher | 20              | Wed Jan 11 12:00:00 -0500 2011 | published          |
      | 7    | teacher | 5               | Wed Jan 10 12:00:00 -0500 2011 | published          |
      | 8    | teacher | 10              | Wed Jan 08 12:00:00 -0500 2011 | published          |
      | 9    | teacher | 20              | Wed Jan 04 12:00:00 -0500 2011 | published          |
      | 10   | teacher | 5               | Wed Jan 05 12:00:00 -0500 2011 | published          |
      | 11   | teacher | 10              | Wed Jan 12 12:00:00 -0500 2011 | published          |
      | 12   | teacher | 20              | Wed Jan 13 12:00:00 -0500 2011 | published          |
      | 13   | teacher | 5               | Wed Jan 09 12:00:00 -0500 2011 | published          |
      | 14   | teacher | 10              | Wed Jan 14 12:00:00 -0500 2011 | published          |
      | 15   | teacher | 20              | Wed Jan 15 12:00:00 -0500 2011 | published          |
      | 16   | teacher | 5               | Wed Jan 16 12:00:00 -0500 2011 | published          |
      | 17   | teacher | 10              | Wed Jan 24 12:00:00 -0500 2011 | published          |
      | 18   | teacher | 20              | Wed Jan 23 12:00:00 -0500 2011 | published          |
      | 19   | teacher | 5               | Wed Jan 22 12:00:00 -0500 2011 | published          |
      | 20   | teacher | 10              | Wed Jan 21 12:00:00 -0500 2011 | published          |
      | 21   | teacher | 11              | Wed Jan 25 12:00:00 -0500 2011 | published          |
      | 22   | teacher | 6               | Wed Jan 26 12:00:00 -0500 2011 | published          |
      | 23   | teacher | 22              | Wed Jan 27 12:00:00 -0500 2011 | published          |
      | 24   | teacher | 33              | Wed Jan 28 12:00:00 -0500 2011 | published          |
    When I am on the investigations page
    Then I should see "Previous"
    And I should see "Next"
    When I check "show count:"
    And I wait for all pending requests to complete
    Then I should see "assigned 5 times"
    And I should see "assigned 10 times"
    And I should see "assigned 20 times"
    When I follow "Next"
    Then I should see "assigned 11 times"
    And I should see "assigned 6 times"
    And I should see "assigned 22 times"
    And I should see "assigned 33 times"
    And the checkbox for "show count:" should be checked
    When I uncheck "show count:"
    Then I should see "21"
    But I should not see "assigned 11 times"
