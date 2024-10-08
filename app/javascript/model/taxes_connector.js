import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const SERVICE_URL = API_URL + '/taxes/'

export default {
    find(context) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
                method: 'get',
                url: SERVICE_URL
            }).then(function(response) {
                if (response.status === 200) {
                    context.taxes = response.data.response
                    console.log(context.taxes)
                }
            })
            .catch(function(error) {
                util.processErrorMsgs(error, context)
            })
    },
    findOne(context, taxId, year) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: SERVICE_URL + taxId + '/' + year
        }).then(function(response) {
            console.log('new taxes')
            console.log(response.data)
            console.log(JSON.stringify(response.data.response[0].years[0].taxDetails.length))
            context.taxesForUpdate = response.data.response[0].years[0].taxDetails
            context.paginate()
            context.summarize()

        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    },
    addTax(context, taxInfo) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'post',
            url: SERVICE_URL,
            data: taxInfo
        }).then(function(response) {
            if (response.data.response) {
                context.closeDialog(true)
                context.$message({
                    type: 'success',
                    message: 'Impuesto agregado exitosamente'
                })
                context.$emit('refresh')
            }
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    }
}