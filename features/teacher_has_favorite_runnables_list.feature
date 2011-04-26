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
      | name           | teacher |
      | My Class       | teacher |
      | My Other Class | teacher |
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

  @javascript
  Scenario: Teacher assigns favorite runnable
    Given the investigation "Argle" is a favorite for the teacher "teacher"
    When I am on the class page for "My Class"
    Then I should see "Your Favorite Assignments"
    And I should see the investigation "Argle" in the favorite assignments listing
    When I drag the favorite investigation "Argle" to "#clazz_offerings"
    And I wait "2" seconds
    Then the investigation named "Argle" should have "offerings_count" equal to "1"
    And I should see the investigation "Argle" in the favorite assignments listing

  @javascript
  Scenario: Can not assign duplicate runnables
    Given the resource page "Newest" is a favorite for the teacher "teacher"
    When I assign the resource page "Newest" to the class "My Class"
    And I am on the class page for "My Class"
    Then I should not see the resource page "Newest" in the favorite assignments listing
    When I am on the class page for "My Other Class"
    Then I should see the resource page "Newest" in the favorite assignments listing

  @javascript
  Scenario: Favorites feature can be enabled via setting
    Given the following users exist:
      | login       | password       | roles                 |
      | admin_login | admin_password | admin, member, author |
    And I login with username: admin_login password: admin_password
    And I am on the admin projects page
    Then I should see "RITES Investigations"
    And I should see "Default Class: disabled"
    When I follow "edit project"
    Then I should see "Enable Teacher Favorites"
    When I check "Enable Teacher Favorites"
    And I press "Save"
    Then I should see "Teacher Favorites: enabled"
    When I follow "edit project"
    Then I should see "Enable Teacher Favorites"
    When I uncheck "Enable Teacher Favorites"
    And I press "Save"
    Then I should see "Teacher Favorites: disabled"
