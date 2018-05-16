Feature: vizualizar balances
  Como Pablo
  Quiero visualizar los balances existentes en K.co
  Para acceder fácilmente a ellos

  @javascript
  Scenario: view balances table
    Given I have 5 balances in the db
    And I logged
    Then I should see the balances table