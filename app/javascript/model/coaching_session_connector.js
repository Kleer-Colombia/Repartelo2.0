import axios from 'axios'
import util from './util'
import router from '../router'

const API_URL = util.apiUrl()
const SERVICE_URL = API_URL + '/balance/'
const CREATE_URL = '/coachingSessions/new'

export default {

  create (context, coachingSession, balanceId) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: SERVICE_URL + balanceId + CREATE_URL,
      data: { coaching_session: coachingSession, balanceId: balanceId }
    }).then(function (response) {
      if (response.status === 200) {
        context.$message({
          type: 'success',
          message: 'Registro de coaching guardado'
        })
        context.visible = false
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  }
}