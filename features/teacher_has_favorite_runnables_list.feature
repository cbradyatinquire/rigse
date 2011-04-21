Feature: Teacher has favorite runnables list

  In order to better organize potential runnables
  As a teacher
  I want to maintain a list of favorite runnables to assign

  Background:
    Given The default project and jnlp resources exist using factories
    And the following teachers exist:
      | login   | password |
      | teacher | teacher  |
    And the following classes exist:
      | name     | teacher |
      | My Class | teacher |
    And the following investigations exist:
      | name   | user    | publication_status |
      | Argle  | teacher | published          |
      | Bargle | teacher | published          |
    And the following resource pages exist:
      | name   | user    | publication_status |
      | Newest | teacher | published          |
      | Medium | teacher | published          |
    And the following external activity exists:
      | name        | user    | url   |
      | My Activity | teacher | /home |
    And I login with username: teacher password: teacher

  @javascript
  Scenario: Teacher marks runnable as favorite
    When I am on the class page for "My Class"
    Then I should see "Argle"
    And the investigation "Argle" should have a favorite link
    When I click the favorite link for the investigation "Argle"
    Then the investigation "Argle" should be a favorite of the teacher "teacher"
    When I click the favorite link for the resource page "Newest"
    Then the resource page "Newest" should be a favorite of the teacher "teacher"
    When I click the favorite link for the external activity "My Activity"
    Then the external activity "My Activity" should be a favorite of the teacher "teacher"
    When I am on the class page for "My Class"
    Then I should see "Your Favorite Assignments"
    And I should see the investigation "Argle" in the favorite assignments listing
    And I should see the resource page "Newest" in the favorite assignments listing
    And I should see the external activity "My Activity" in the favorite assignments listing

  @javascript
  Scenario: Teacher removes runnable from favorites
    Given the investigation "Argle" is a favorite for the teacher "teacher"
    When I am on the class page for "My Class"
    Then I should see "Your Favorite Assignments"
    And I should see the investigation "Argle" in the favorite assignments listing
    When I click the remove favorite link for the investigation "Argle"
    Then the investigation "Argle" should not be a favorite of the teacher "teacher"

  @javascript
  Scenario: Favorites can not be duplicates
    When I am on the class page for "My Class"
    Then I should see "Argle"
    And the investigation "Argle" should have a favorite link
    When I click the favorite link for the investigation "Argle"
    Then the investigation "Argle" should be a favorite of the teacher "teacher"
    When I click the favorite link for the investigation "Argle"
    Then there should only be one instance of the investigation "Argle" in the favorites of the teacher "teacher"
    When I am on the class page for "My Class"
    Then I should see "Your Favorite Assignments"
    And I should see the investigation "Argle" in the favorite assignments listing

  @wip
  Scenario: Teacher assigns favorite runnable
