import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const PAYMENTS_URL = API_URL + '/payments/'
const SYNC_URL = API_URL + '/invoice/sync'

export default {

    // status: 'pending' | 'paid'; year solo aplica a 'paid'.
    find(context, status, year) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        context.loading = true
        axios({
            method: 'get',
            url: PAYMENTS_URL,
            params: { status: status, year: year }
        }).then(function(response) {
            const data = response.data.response
            context.invoices = data.invoices
            context.lastSync = data.lastSync
            context.driveConfigured = data.driveConfigured
            context.loading = false
        }).catch(function(error) {
            context.loading = false
            util.processErrorMsgs(error, context)
        })
    },

    register(context, number, payment, onSuccess) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        context.saving = true
        axios({
            method: 'post',
            url: PAYMENTS_URL + encodeURIComponent(number),
            data: { payment: payment }
        }).then(function(response) {
            context.saving = false
            const updated = response.data.response.updatedBalances || []
            context.$message({
                type: 'success',
                message: 'Pago registrado' + (updated.length ? ' (balances actualizados: ' + updated.join(', ') + ')' : '')
            })
            onSuccess()
        }).catch(function(error) {
            context.saving = false
            util.processErrorMsgs(error, context)
        })
    },

    remove(context, number, onSuccess) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'delete',
            url: PAYMENTS_URL + encodeURIComponent(number)
        }).then(function() {
            context.$message({ type: 'success', message: 'La factura ' + number + ' volvió a pendientes' })
            onSuccess()
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    },

    syncDrive(context, onSuccess) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        context.syncing = true
        axios({
            method: 'post',
            url: SYNC_URL
        }).then(function(response) {
            context.syncing = false
            const run = response.data.response
            if (run.error) {
                context.$message({ type: 'error', message: 'Error leyendo el Drive: ' + run.error, duration: 8000 })
            } else {
                const s = run.summary || {}
                context.$message({
                    type: 'success',
                    message: 'Drive leído: ' + (s.new_invoices || 0) + ' facturas nuevas, ' + (s.annulled || 0) + ' anuladas'
                })
            }
            onSuccess()
        }).catch(function(error) {
            context.syncing = false
            util.processErrorMsgs(error, context)
        })
    }
}
