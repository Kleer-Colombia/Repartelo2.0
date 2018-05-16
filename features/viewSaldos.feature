Feature: vizualizar saldos
  Como Yamit
  Quiero visualizar los saldos de todos los kleerers
  Para fomentar la transparencia en el equipo

  @javascript
  Scenario: view saldos
    Given I have kleerers
    And I logged
    When I go to the "Saldos" option
    Then I should see the saldos home page
    And I see the data for all kleerers

  @javascript
  Scenario: view saldos details
    Given I have kleerers
    And I logged
    And I have 1 distributed balances
    When I go to the "Saldos" option
    Then I see the money distribution for all of them

  @javascript
  Scenario: view saldos details with multiple balances
    Given I have kleerers
    And I logged
    And I have 3 distributed balances
    When I go to the "Saldos" option
    Then I see the money distribution for all of them