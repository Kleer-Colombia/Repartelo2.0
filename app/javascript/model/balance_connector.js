import axios from 'axios'
import util from './util'
import router from '../router'

const API_URL = util.apiUrl()
const BALANCE_URL = API_URL + '/balance'
const CLOSE_BALANCE_URL = BALANCE_URL + '/close'
const NEW_BALANCE_URL = BALANCE_URL + '/new'
const KLEERERS_URL = API_URL + '/kleerers/filter'

export default {

  distribute (context, data) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: BALANCE_URL,
      data: data
    }).then(function (response) {
      context.$emit('input', response.data.response)
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  close (context, data) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: CLOSE_BALANCE_URL,
      data: data
    }).then(function (response) {
      if (response.status === 200) {
        context.$message({
          type: 'success',
          message: 'Balance enviado a saldos exitosamente'
        })
        context.balance.editable = false
      }
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  deleteBalance (context, idBalance) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'delete',
      url: BALANCE_URL + '/' + idBalance
    }).then(function (response) {
      if (response.status === 200) {
        router.push('/balance')
        context.$message({
          type: 'success',
          message: 'Borrado Exitoso'
        })
      }
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  createBalance (context, balance) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: NEW_BALANCE_URL,
      data: balance
    }).then(function (response) {
      var id = response.data.response
      router.push('/balance/' + id)
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  findBalance (context, nextFunction) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: BALANCE_URL + '/' + context.$route.params.id
    }).then(function (response) {
      var balance = response.data.response
      context.balance = balance.balance
      console.log(balance.balance)
      context.incomes.realIncomes = balance.incomes.incomes
      context.incomes.totalIncomes = balance.incomes.total
      context.expenses.realExpenses = balance.expenses.expenses
      context.expenses.totalExpenses = balance.expenses.total
      context.distribution.balancePercentages = balance.percentages
      if (balance.distributions.length > 0) {
        context.distribution.result = balance.distributions
      }
      if (nextFunction) {
        nextFunction(context)
      }
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  findBalances (context) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: BALANCE_URL
    }).then(function (response) {
      context.balances = response.data.response
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  addIncome (context, id) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      data: {income: context.income},
      url: BALANCE_URL + '/' + id + '/income'
    }).then(function (response) {
      var answer = response.data.response
      context.realIncomes = answer.incomes
      context.$emit('input', answer.total)
      context.income.description = ''
      context.income.amount = ''
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  removeIncome (context, id, idIncome) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'delete',
      url: BALANCE_URL + '/' + id + '/income/' + idIncome
    }).then(function (response) {
      var answer = response.data.response
      context.realIncomes = answer.incomes
      context.$emit('input', answer.total)
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  addExpense (context, id) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      data: {expense: context.expense},
      url: BALANCE_URL + '/' + id + '/expense'
    }).then(function (response) {
      var answer = response.data.response
      context.realExpenses = answer.expenses
      context.$emit('input', answer.total)
      context.expense.description = ''
      context.expense.amount = ''
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  removeExpense (context, id, idExpense) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'delete',
      url: BALANCE_URL + '/' + id + '/expense/' + idExpense
    }).then(function (response) {
      var answer = response.data.response
      context.realExpenses = answer.expenses
      context.$emit('input', answer.total)
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  updateKleerersPercentages (context, idBalance, kleerers) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      data: {kleerers: kleerers},
      url: BALANCE_URL + '/' + idBalance + '/percentages'
    }).then(function (response) {
      response.data.response
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  getKleerers (context, nextFunction) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: KLEERERS_URL
    }).then(function (response) {
      context.distribution.kleerers = response.data.response
      for (var i = 0; i < context.distribution.kleerers.length; i++) {
        context.distribution.kleerers[i].selected = false
        context.distribution.kleerers[i].value = 0
      }
      if (nextFunction) {
        nextFunction(context)
      }
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  }
}
