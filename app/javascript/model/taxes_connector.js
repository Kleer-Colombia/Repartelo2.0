import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const SERVICE_URL = API_URL + '/taxes/'

export default {
  find (context) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: SERVICE_URL
    }).then(function (response) {
      if (response.status === 200) {
        context.taxes = response.data.response
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  },
  findOne (context, taxId) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: SERVICE_URL + taxId
    }).then(function (response) {
      //TODO context.saldo = response.data.response
    }).catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },
  addTax (context, taxInfo) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: SERVICE_URL,
      data: taxInfo
    }).then(function (response) {
      if (response.data.response) {
        context.closeDialog(true)
        context.$message({
          type: 'success',
          message: 'Inpuesto agregado exitosamente'
        })
        context.$emit('refresh')
      }
    }).catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  }
}
