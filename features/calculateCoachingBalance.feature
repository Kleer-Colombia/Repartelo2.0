Feature:
  As Yamit
  I want to calculate a coaching balance
  In order to know what is the money distribution

  @javascript
  Scenario: calculate coaching balance with yamit as a kleerer
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Socio     |
    And I close the coaching sessions admin
    And I add income for "1100.00"
    And I add expense for "100.00"
    And I distribute the profit
    Then I should see "$202,00" for "KleerCo"
    And I should see "$798,00" for "Socio"

  @javascript
  Scenario: calculate balance with negative profit
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Full      |
    And I close the coaching sessions admin
    And I add income for "100.00"
    And I add expense for "1100.00"
    And I distribute the profit
    Then I should the an invalid profit distribution error

  @javascript
  Scenario: calculate distributions with Full and Socio
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Full      |
      |Some description|Socio     |
    And I close the coaching sessions admin
    And I add income for "1100.00"
    And I add expense for "200.00"
    When I distribute the profit
    Then I should see "$321,30" for "Full"
    And I should see "$359,10" for "Socio"
    And I should see "$219,60" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full and Socio on 70/30
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Socio     |
      |Some description|Socio     |
      |Some description|Socio     |
    And I close the coaching sessions admin
    And I add income for "1100.00"
    And I add expense for "200.00"
    When I distribute the profit
    Then I should see "$449,82" for "Full"
    And I should see "$215,46" for "Socio"
    And I should see "$234,72" for "KleerCo"

  @javascript
  Scenario: calculate distributions with Full, Socio and Partial with  custom values
    Given I have data for balances
    And I logged
    And I have kleer tax
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Full      |
      |Some description|Parcial   |
      |Some description|Socio     |
      |Some description|Socio     |
      |Some description|Socio     |
      |Some description|Socio     |
    And I close the coaching sessions admin
    And I add income for "1000.00"
    When I distribute the profit
    Then I should see "$357,00" for "Full"
    And I should see "$319,20" for "Socio"
    And I should see "$63,00" for "Parcial"
    And I should see "$260,80" for "KleerCo"

