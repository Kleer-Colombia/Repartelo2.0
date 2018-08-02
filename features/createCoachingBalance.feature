Feature:
  As Yamit
  I want to create a new coaching balance
  In order to replace google sheets

  @javascript
  Scenario: create new coaching balance
    Given I logged
    When I create a new coaching balance for client "Sparkta"
    Then I should the principal page for the balance
    And I should have an option to admin coaching sessions
