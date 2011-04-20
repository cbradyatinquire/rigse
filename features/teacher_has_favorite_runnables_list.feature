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

  @javascript
  Scenario: Teacher marks runnable as favorite
    Given I login with username: teacher password: teacher
    When I am on the class page for "My Class"
    Then I should see "Argle"
    And the investigation "Argle" should have a favorite link
    When I click the favorite link for the investigation "Argle"
    Then the investigation "Argle" should be a favorite of the teacher "teacher"
    When I click the favorite link for the resource page "Newest"
    Then the resource page "Newest" should be a favorite of the teacher "teacher"
