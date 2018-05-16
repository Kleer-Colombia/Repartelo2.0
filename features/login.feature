Feature: user identification
    As Camilo
    I want to login
    In order to secure my personal data

  @javascript
  Scenario: good login
      Given i have a user in the db
      When i do login
      Then i should see the balances homepage

  @javascript
  Scenario: bad login
    Given i have an invalid user
    When i do login
    Then i should see invalid user and password