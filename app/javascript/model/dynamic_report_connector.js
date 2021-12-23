import axios from 'axios'
import until from './util'

const kleerCoIndex = 5
const API_URL = until.apiUrl()
const kleerCoURL = `${API_URL}/objectives`

export default {
  getData(context, nextFunction) {
    axios.defaults.headers.common['Authorization'] = until.getAuthHeader()
    axios({
      method: 'get',
      url: kleerCoURL
    }).then(response => {
      context.kleerCo = response.data.response.total
      context.kleerers = response.data.response.kleerers
      console.log(context)
      if (nextFunction) {
        nextFunction(context)
      }
    }).catch(error => {
      until.processErrorMsgs(error)
    })
  }
}
