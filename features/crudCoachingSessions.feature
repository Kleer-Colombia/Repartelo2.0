Feature:
  As kleerer
  I want to create admin the coaching sessions in a balance
  In order to support coaching balances.

  @javascript
  Scenario: add single coaching session
    Given I logged
    And I have kleerers
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add a new session with "some description" and the kleerers "Socio"
    Then I should see the coaching session table with 1 registry
    And I should the coaching sessions summary
