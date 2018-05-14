import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const KLEERERS_URL = API_URL + '/kleerers'

export default {

  getKleerers (context) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: KLEERERS_URL
    }).then(function (response) {
      context.kleerers = response.data.response
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  }
}
