Feature:
  As Yamit
  I want to delete balances
  In order clean wrong balances

  @javascript
  Scenario: delete balance
    Given I logged
    And I don't have any balance
    And I create a new standard balance for client "Sparkta"
    When I delete the balance
    And Confirm the elimination
    Then I should the Balance home page empty