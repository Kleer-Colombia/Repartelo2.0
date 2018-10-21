import axios from 'axios'
import util from './util'
import router from '../router'

const API_URL = util.apiUrl()
const SERVICE_URL = API_URL + '/balance/'
const CREATE_URL = '/coachingSessions/new'
const FIND_URL = '/coachingSessions/'
const DELETE_URL = '/coachingSessions/'
const SUMMARY_URL = '/coachingSessions/summary'

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
        context.updateData()
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  },
  find (context, balanceId) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'get',
      url: SERVICE_URL + balanceId + FIND_URL
    }).then(function (response) {
      if (response.status === 200) {
        for (var i = 0; i < response.data.response.length; i++) {
          response.data.response[i].kleerers = response.data.response[i].kleerers.join(', ')
        }
        context.sessions = response.data.response
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  },
  delete (context, balanceId, csId) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'delete',
      url: SERVICE_URL + balanceId + DELETE_URL + csId
    }).then(function (response) {
      if (response.status === 200) {
        context.$message({
          type: 'success',
          message: 'Eliminación exitosa'
        })
        context.updateList()
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  },
  summary (context, balanceId, isNeededUpdatePercentage) {
    axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
    axios({
      method: 'post',
      url: SERVICE_URL + balanceId + SUMMARY_URL,
      data: { updatePercentage: isNeededUpdatePercentage }
    }).then(function (response) {
      if (response.status === 200) {
        context.summary = response.data.response
      }
    })
      .catch(function (error) {
        util.processErrorMsgs(error, context)
      })
  }
}
