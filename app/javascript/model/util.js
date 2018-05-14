import auth from './auth'

export default {
  // The object to be passed as a header for authenticated requests
  getAuthHeader () {
    return 'Bearer ' + this.checkAuth('access_token')
  },
  checkAuth () {
    return localStorage.getItem('access_token')
  },
  formatPrice (value) {
    let val = (value / 1).toFixed(2).replace('.', ',')
    val = val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
    return '$' + val
  },
  apiUrl () {
    return this.loginUrl() + 'api/v1'
  },
  loginUrl () {
    return 'http://' + window.location.hostname + ':' + process.env.API_PORT + '/'
  },
  processErrorMsgs (error, context) {
    console.log(error)
    console.log(error.response)
    if (error.response) {
      if (error.response.status === 403) {
        this.manageAuthError(error, context)
      } else if (error.response.status === 404) {
        this.manageSrvNotFoundError(context)
      } else {
        context.$message({
          type: 'error',
          message: error.response.data.message,
          duration: 6000
        })
      }
    } else {
      this.manageSrvNotFoundError(context)
    }
  },
  manageAuthError (error, context) {
    auth.logout()
    context.$message({
      type: 'error',
      message: error.response.data.message,
      duration: 6000
    })
  },
  manageSrvNotFoundError (context) {
    context.$message({
      type: 'error',
      message: 'Uyyyy algo le paso al back :/',
      duration: 6000
    })
  }
}