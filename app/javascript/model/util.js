import auth from './auth'

export default {
  // The object to be passed as a header for authenticated requests
    validURL(str) {
    var pattern = new RegExp('^(https?:\/\/)?'+ // protocol
        '((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|'+ // domain name
        '((\d{1,3}\.){3}\d{1,3}))'+ // OR ip (v4) address
        '(\:\d+)?(\/[-a-z\d%_.~+]*)*'+ // port and path
        '(\?[;&a-z\d%_.~+=-]*)?'+ // query string
        '(\#[-a-z\d_]*)?$','i'); // fragment locater
    return !pattern.test(str)
},
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
    return this.baseUrl() + 'api/v1'
  },
  baseUrl () {
      let url = window.location.protocol + '//' + window.location.hostname
      if (window.location.port != "") {
          url = url + ':' + window.location.port + '/'
      }else {
          url = url + '/'
      }
    return url
  },
  processErrorMsgs (error, context) {
    console.log(error)
    console.log('---->' + error.response)
    if (error.response) {
      if (error.response.status === 401) {
        this.manageAuthError(error, context)
      } else if (error.response.status === 404) {
        this.manageSrvNotFoundError(context)
      } else {
        context.$message({
          type: 'error',
          message: 'Error: ' +error.response.status + ':' +error.response.data.message,
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
