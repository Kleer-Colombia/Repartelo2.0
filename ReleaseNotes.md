TODO:
    
    extraer botton de distribuir como componente, actualmente en KleerersDistribution y AdminCoachingLogButton
    
    
    al cerrar el balance, verificar que la factura este usada al 100% y avisar!!!
    
    consider to remove the invoice_id and the invoice_date from taxes.
    para remover invoice_date e invoice ID, deben cambiar metodo de busqueda en balance por invoice_date y el consolidador de taxes.
    
Version 2.4
    
    - Selecionar factura por porcentajes
    - selecion con decimales
    - Iva acumulativo para multiples facturas
        
    
Version 2.3

    - Taxes view con paginacion
    - seed for iva 0 in tax master
    - admin for feature flags
    - update version of vue and element.io
    - filtros de busqueda pagina de balances

Version 2.2
   
    - Dockerized app for acceptance test
    - Service layer refactors
    - taxes calculations
    - import and use invoices for alegra
    - feature flags for invoice and incomes

Version 2.1
    
    - Balances de tipo coaching con calculo y distribucion.

Version 2.0

    - Migracion a rails 5.1 con Vue.js 
    - Agregado active admin para kleerers y users
    - Eliminado el uso de docker y kubernetes y produccion es n Heroku.

Version 1.1.0

    - agregada pagina de slados por kleerer
    - agregada funcionalidad para cerrar balances
    - ahora un balance cerrado va a saldos directamente
    - agregado el input money
    - es posible agregar saldos manualmente ( ingresos y egresos)
    - implica cambios en DB
    - mejor manejo de errores y cierre de sesion al cambiar el token de auth

Version 1.0.1

    - agregada funcionalidad para borrar un balance.
