Feature:
  As Yamit
  I want to create a new standard balance
  In order to replace google sheets

  @javascript
  Scenario: create new standard balance
    Given I logged
    When I create a new standard balance for client "Sparkta"
    Then I should the principal page for the balance

  @javascript
  Scenario: create new standard balance
    Given I logged
    When I create a new standard balance for client ""
    Then I should the an error message

  @javascript
  Scenario: create new standard balance with one income
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Sparkta"
    When I add income for "1000.00"
    Then I should see "$1.000,00" for total "incomes"

  @javascript
  Scenario: create new standard balance with many incomes
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Corb"
    When I add income for "1000.57"
    When I add income for "5500.00"
    When I add income for "23050.00"
    Then I should see "$29.550,57" for total "incomes"

  @javascript
  Scenario: remove income
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Corb"
    When I add income for "1000.57"
    When I add income for "5500.50"
    When I remove income for "5500.5"
    Then I should see "$1.000,57" for total "incomes"

  @javascript
  Scenario: create new standard balance with one expense
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Sparkta"
    When I add expense for "1000.00"
    Then I should see "$1.000,00" for total "expenses"

  @javascript
  Scenario: create new standard balance with many incomes
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Corb"
    When I add expense for "1000.57"
    When I add expense for "5500.00"
    When I add expense for "23050.00"
    Then I should see "$29.550,57" for total "expenses"

  @javascript
  Scenario: remove income
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Corb"
    When I add expense for "1000.57"
    When I add expense for "5500.50"
    When I remove expense for "5500.5"
    Then I should see "$1.000,57" for total "expenses"

  @javascript
  Scenario: find profit
    Given I have data for balances
    And I logged
    And I create a new standard balance for client "Corb"
    When I add expense for "10000.00"
    When I add income for "1500.00"
    When I add income for "5500.57"
    When I add income for "23000.00"
    Then I should see "$20.000,57" for total "profit"