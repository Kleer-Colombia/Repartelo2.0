Feature:
  As Yamit
  I want to calculate a balance
  In order to know what is the money distribution

  @javascript
  Scenario: calculate balance with yamit as a kleerer
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new standard balance for client "Sparkta"
    And I add the invoice 531
    And I add expense for "100.00"
    When I select "Socio" as a kleerer
    And I distribute the profit
    Then I should see "$3.835.656,80" for "KleerCo"
    And I should see "$15.152.743,20" for "Socio"

