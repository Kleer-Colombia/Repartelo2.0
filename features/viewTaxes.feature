Feature: vizualizar saldos
  Como Kleerer
  Quiero visualizar los impuestos reservados de todos los balances
  Para saber si debemos o no reservar mas

  @javascript
  Scenario: view taxes
    And I have taxes
    And I have data for taxes
    And I logged
    When I go to the "Impuestos" option
    Then I should see the Impuestos home page
    And I see the data for all taxes