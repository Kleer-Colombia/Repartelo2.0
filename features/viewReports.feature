Feature: visualizar informes dinamicos
  Como financiera
  Quiero visualizar el valor total de aportes a Kleer Colombia acumulados en el año en curso
  Para determinar si se logró la meta de ventas anual y hacer seguimiento a la misma.

  @javascript
  Scenario: view global KleerCo report
    And I have data for balances
    And I logged
    When I go to the "Reportes-dinamicos" option
    When I should see the total for KleerCo

