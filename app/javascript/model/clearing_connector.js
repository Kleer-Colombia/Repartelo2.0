import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const CLEARING_URL = API_URL + '/clearing/'

export default {
    find(context, countryId) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: CLEARING_URL + countryId
        }).then(function(response) {
            context.clearing = response.data.response
            console.log(response)
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    }
}