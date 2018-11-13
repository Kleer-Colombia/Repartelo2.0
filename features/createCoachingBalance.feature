Feature:
  As Yamit
  I want to create a new coaching balance
  In order to replace google sheets

  @javascript
  Scenario: create new coaching balance
    Given I logged
    When I create a new coaching balance for client "Sparkta"
    Then I should the principal page for the balance
    And I should have an option to admin coaching sessions

  @javascript
  Scenario: load coaching balance info
    Given I logged
    And I have kleerers
    And I create a new coaching balance for client "Sparkta"
    And I open the coaching sessions admin
    And I add many new sessions
      |description     | kleerers |
      |Some description|Socio     |
      |Some description|Full      |
    And I close the coaching sessions admin
    And I go to the "Balances" option
    When I select de edit option
    Then I should the coaching sessions summary
      |kleerer|sessions|percentage|
      |Socio  | 1      |  50      |
      |Full   | 1      |  50      |