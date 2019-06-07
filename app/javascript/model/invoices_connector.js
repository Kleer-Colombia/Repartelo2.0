import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const INVOICE_URL = API_URL + '/invoice'

export default {

  findInvoices (context) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: INVOICE_URL
    }).then(function (response) {
      context.invoices = response.data.response
      context.loaded = true
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  }
}
