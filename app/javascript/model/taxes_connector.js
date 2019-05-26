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
  }
}
