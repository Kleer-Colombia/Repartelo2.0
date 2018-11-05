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
    |kleerer|sessions|percentage|
    |Socio  | 1      |  100     |


  @javascript
  Scenario: add one coaching session with some kleerers
    Given I logged
    And I have kleerers
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add a new session with "some description" and the kleerers "Socio,Full"
    Then I should see the coaching session table with 1 registry
    And I should the coaching sessions summary
    |kleerer|sessions|percentage|
    |Socio  | 0.5    |  50      |
    |Full   | 0.5    |  50      |

  @javascript
  Scenario: add many coaching session with some kleerers
    Given I logged
    And I have kleerers
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
    |description     | kleerers |
    |Some description|Socio,Full|
    |Some description|Socio     |
    |Some description|Full      |
    |Some description|Parcial,Full|
    |Some description|Socio,Full|
    |Some description|Socio,Full|
    Then I should see the coaching session table with 6 registry
    And I should the coaching sessions summary
      |kleerer|sessions|percentage|
      |Socio  | 2.5    |  41.67   |
      |Full   | 3      |  50      |
      |Parcial| 0.5    |  8.33    |

  @javascript
  Scenario: add many coaching and delete sessions with some kleerers
    Given I logged
    And I have kleerers
    And I create a new coaching balance for client "Sparkta"
    When I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Socio,Full|
      |Some description|Socio     |
      |Some description|Full      |
      |Some description|Parcial,Full|
    And I delete the 4 session
    And I add a new session with "some description" and the kleerers "Socio,Full"
    Then I should see the coaching session table with 4 registry
    And I should the coaching sessions summary
      |kleerer|sessions|percentage|
      |Socio  | 2      |  50      |
      |Full   | 2      |  50      |
