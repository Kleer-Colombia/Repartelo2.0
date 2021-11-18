import Vue from 'vue'
import Router from 'vue-router'
import Login from '../components/Login'
import Balance from '../components/balances/Balance'
import NewBalance from '../components/balances/NewBalance'
import DetailBalance from '../components/balances/DetailBalance'
import Saldos from '../components/saldos/Saldos'
import Taxes from '../components/taxes/Taxes'
import Reports from '../components/reports/Reports'
import DynamicReports from '../components/dynamic_reports/DynamicReports'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      redirect: '/login'
    },
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/balance',
      name: 'balance',
      component: Balance
    },
    {
      path: '/balance/new',
      name: 'newBalance',
      component: NewBalance
    },
    {
      path: '/balance/:id',
      name: 'detailBalance',
      component: DetailBalance
    },
    {
      path: '/saldos',
      name: 'saldos',
      component: Saldos
    },
    {
      path: '/impuestos',
      name: 'impuestos',
      component: Taxes
    },
    {
      path: '/reportes',
      name: 'reportes',
      component: Reports
    },
    {
      path: '/reportes-dinamicos',
      name: 'reportes-dinamicos',
      component: DynamicReports
    }
  ]
})
