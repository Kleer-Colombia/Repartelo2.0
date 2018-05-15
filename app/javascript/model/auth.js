import router from '../router'
import axios from 'axios'
import util from './util'
// URL and endpoint constants
const API_URL = util.apiUrl()
const LOGIN_URL = API_URL + '/login'

export default {

  // Send a request to the login URL and save the returned JWT
  login (context, creds, redirect) {
    axios({
      method: 'post',
      url: LOGIN_URL,
      data: creds
    }).then(function (response) {
      localStorage.setItem('access_token', response.data.token)
      // Redirect to a specified route
      if (redirect) {
        router.push(redirect)
      }
    })
    .catch(function (error) {
      util.processErrorMsgs(error, context)
    })
  },

  // To log out, we just need to remove the token
  logout () {
    localStorage.removeItem('access_token')
    router.push('/login')
  }
}
