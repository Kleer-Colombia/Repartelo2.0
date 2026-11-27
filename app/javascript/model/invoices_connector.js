import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const INVOICE_URL = API_URL + '/invoice'

export default {

    // Facturas de venta disponibles para agregar a un balance (vienen del
    // Drive de contabilidad).
    findInvoices(context) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
                method: 'get',
                url: INVOICE_URL
            }).then(function(response) {
                const data = response.data.response
                context.invoices = data.invoices
                context.lookbackMonths = data.months
                context.lastSync = data.lastSync
                context.loaded = true
            })
            .catch(function(error) {
                context.loaded = true
                util.processErrorMsgs(error, context)
            })
    }
}
