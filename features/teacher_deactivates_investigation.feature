Feature: Teacher can deactivate investigations from a class
  So my class can move on to other things
  As a teacher
  I want to unassign investigations from a class
  
  Background:
    Given The default project and jnlp resources exist using factories
  
  @selenium
  Scenario: Teacher can see if student has performed work on an investigation
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigation exists:
      | name                | user      |
      | Test Investigation  | teacher   |
    When I assign the investigation "Test Investigation" to the class "My Class"
    And a student has performed work on the investigation "Test Investigation" for the class "My Class"
    And I login with username: teacher password: teacher
    And I am on the class page for "My Class"
    And I open the accordion for the offering for investigation "Test Investigation" for the class "My Class"
    Then I should see "1 student response"
        
    When I follow "deactivate" on the investigation "Test Investigation" from the class "My Class"
    And I am on the class page for "My Class"
    Then I should not see "0 student responses"
    And I should see "1 student response"
    
    When I follow "activate" on the investigation "Test Investigation" from the class "My Class"
    And I am on the class page for "My Class"
    Then I should not see "0 student responses"
    And I should see "1 student response"
    
  @selenium
  Scenario: Teacher drags active investigation with students off of class
    Given the following teachers exist:
      | login         | password        |
      | teacher       | teacher         |
    And the following classes exist:
      | name      | teacher     |
      | My Class  | teacher     |
    And the following investigation exists:
      | name                | user      |
      | Test Investigation  | teacher   |
    When I assign the investigation "Test Investigation" to the class "My Class"
    And a student has performed work on the investigation "Test Investigation" for the class "My Class"
    And I login with username: teacher password: teacher
    And I am on the class page for "My Class"
    And I drag the investigation "Test Investigation" in the class "My Class" to "#offering_list"
    Then I should see "Cannot delete offering with student data. Please deactivate instead."
    And I should see "Test Investigation" within "#clazz_offerings"
    And the investigation "Test Investigation" in the class "My Class" should be active