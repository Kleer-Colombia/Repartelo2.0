import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const SALDOS_URL = API_URL + '/saldos/'

export default {

    find(context, kleererId) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: SALDOS_URL + kleererId
        }).then(function(response) {
            context.saldo = response.data.response
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    },

    addSaldo(context, saldo) {

        console.log(saldo)
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'post',
            url: SALDOS_URL,
            data: saldo
        }).then(function(response) {
            if (response.data.response) {
                context.closeDialog(true)
                context.$message({
                    type: 'success',
                    message: 'Registro agregado exitosamente'
                })
                context.$emit('refresh')
            }
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    }
}