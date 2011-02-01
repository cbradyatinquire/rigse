Feature: Student can not see deactivated offerings
  In order to only work on active offerings
  As a student
  I do not want to see deactivated offerings
    
  Background:
    Given The default project and jnlp resources exist using factories
    And the following students exist:
      | login     | password  |
      | student   | student   |
    And the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigation exists:
      | name                | user      |
      | Test Investigation  | teacher   |
    And the following resource pages exist:
      | name          | user      |
      | Test Resource | teacher   |
    And the student "student" belongs to class "My Class"
    And I login with username: teacher password: teacher
    When I assign the investigation "Test Investigation" to the class "My Class"
    And I assign the resource page "Test Resource" to the class "My Class"
    
  @selenium
  Scenario: Student should see activated offerings
    When I log out
    And I login with username: student password: student
    Then I should see "run Test Investigation"
    And I should see "View Test Resource"
  
  @selenium
  Scenario: Student should not see deactivated offerings
    When I am on the class page for "My Class"
    And I follow "Deactivate" on the investigation "Test Investigation" from the class "My Class"
    And I follow "Deactivate" on the resource page "Test Resource" from the class "My Class"
    And I log out
    And I login with username: student password: student
    Then I should be on the homepage
    And I should not see "run Test Investigation"
    And I should not see "View Test Resource"
    And I should see "No Investigations available."
    
    When I am on the class page for "My Class"
    And I should not see "run Test Investigation"
    And I should see "No Investigations available."
    And I should not see "View Test Resource"
    
