Feature: An author edits a data collector
  As a Investigations author
  I want to author data collectors in my investigations
  So that I can provoke exploration by my students.
  
  Background:
    Given The default project and jnlp resources exist using mocks

  @javascript
  Scenario: The author edits a graph and sees the Y-axis label and units change as the probe type changes
    Given the following users exist:
      | login        | password            | roles                |
      | author       | author              | member, author       |
    Given the following investigation exists:
      | name                 | description           | user                 |
      | testing fast cars    | how fast can cars go? | author               |
    
    And I login with username: author password: author
    When I show the first page of the "testing fast cars" investigation
    Then I should see "Page: 1"
    When I follow "Graph"
    Then I should see "Data Collector"
    When I follow "edit graph"
    Then I should see "Probe type:"
    When I select "Pressure" from "embeddable_data_collector[probe_type_id]"
    Then the "embeddable_data_collector_y_axis_label" field should contain "Pressure"
    And the "embeddable_data_collector_y_axis_units" field should contain "kPa"