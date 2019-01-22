Feature:
  As a Yamit
  I want to sent to saldos the money distribution for a Balance
  in order to dont allow its edition once it has gone to Saldos

  @javascript
  Scenario: not editable balance
    And I have data for balances
    And I have kleer tax
    And I logged
    When I have 1 distributed balances
    Then I could not edit the balance

  @javascript
  Scenario: not editable coaching balance
    And I have data for balances
    And I have kleer tax
    And I logged
    When I have 1 distributed coaching balance
    Then I could not edit the coaching balance