Feature:
  As a Yamit
  I want to sent to saldos the money distribution for a Balance
  in order to dont allow its edition once it has gone to Saldos

  @javascript
  Scenario: not editable balance
    Given I have kleerers
    And I logged
    When I have 1 distributed balances
    Then I could not edit the balance

  @javascript
  Scenario: not editable coaching balance
    Given I have kleerers
    And I logged
    When I have 1 distributed coaching balance
    Then I could not edit the coaching balance