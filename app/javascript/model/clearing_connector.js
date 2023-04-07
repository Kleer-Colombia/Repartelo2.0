import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const CLEARING_URL = API_URL + '/clearing'

export default {
    find(context, countryId) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: CLEARING_URL //     + countryId
        }).then(function(response) {
            context.clearing = response.data.response
            console.log(response)
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    },

    addClearing(context, clearing) {
        console.log('si entra')
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'post',
            url: CLEARING_URL,
            data: clearing
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
    },
}