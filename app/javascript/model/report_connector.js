import axios from 'axios'
import util from './util'

const FileDownload = require('js-file-download')
const API_URL = util.apiUrl()
const REPORTS_URL = API_URL + '/reports'

export default {

    downloadReport(context, action) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
                method: 'get',
                url: REPORTS_URL + action
            }).then(function(response) {
                console.log(response)
                let headerLine = response.headers['content-disposition']
                let startFileNameIndex = headerLine.indexOf('"') + 1
                let endFileNameIndex = headerLine.lastIndexOf('"')
                let filename = headerLine.substring(startFileNameIndex, endFileNameIndex)
                FileDownload(response.data, filename)
            })
            .catch(function(error) {
                util.processErrorMsgs(error, context)
            })
    },

    addExpensesPack(context, data) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'post',
            url: REPORTS_URL + '/expenses-load',
            data: data
        }).then(response => {
            console.log(response.data.response)
            context.report = response.data.response
            context.loading = false
        }).catch(error => {
            util.processErrorMsgs(error, context)
        })
    },

    addTRM(context, data) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
                method: 'post',
                url: API_URL + '/trm',
                data: data
            }).then(response => {
                console.log(response.data.response)
                context.loading = false
                context.closeDialog(true)
                context.$message({
                    type: 'success',
                    message: 'TRM agregado exitosamente'
                })
            })
            .catch(error => {
                util.processErrorMsgs(error, context)
            })
    }
}