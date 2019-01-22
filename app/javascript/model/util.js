import auth from './auth'

const util = {
  // The object to be passed as a header for authenticated requests
  validURL (str) {
    var regex = /(http|https):\/\/(\w+:{0,1}\w*)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%!\-\/]))?/;
    return regex.test(str)
  },
  getAuthHeader () {
    return 'Bearer ' + this.checkAuth('access_token')
  },
  saveFeatureFlag (featureFlag) {
    localStorage.setItem('feature-flag', JSON.stringify(featureFlag))
  },
  checkFlag (flag) {
    return JSON.parse(localStorage.getItem('feature-flag'))[flag]
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
    return this.baseUrl() + 'api/v1'
  },
  baseUrl () {
    let url = window.location.protocol + '//' + window.location.hostname
    if (window.location.port !== '') {
      url = url + ':' + window.location.port + '/'
    } else {
      url = url + '/'
    }
    return url
  },
  processErrorMsgs (error, context) {
    if (error.response) {
      if (error.response.status === 401) {
        this.manageAuthError(error, context)
      } else if (error.response.status === 404) {
        this.manageSrvNotFoundError(context)
      } else {
        context.$message({
          type: 'error',
          message: 'Error: ' + error.response.status + ':' + error.response.data.message,
          duration: 6000
        })
      }
    } else {
      this.manageSrvNotFoundError(error, context)
    }
  },
  manageAuthError (error, context) {
    auth.logout()
    context.$message({
      type: 'error',
      message: 'Error de sesión: ' + error.response.data.message,
      duration: 6000
    })
  },
  manageSrvNotFoundError (error, context) {
    context.$message({
      type: 'error',
      message: 'Uyyyy algo paso: ' + error,
      duration: 6000
    })
  }
}
export default util
