import axios from 'axios'
import util from './util'
import router from '../router'

const API_URL = util.apiUrl()
const COUNTRIES_URL = API_URL + '/countries/'

export default {
    getCountries: (context, actions) => {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: COUNTRIES_URL
        }).then(response => {
            context.countries = response.data.response
            console.log('countries', response)
            actions()
        }).catch(error => {
            util.processErrorMsgs(error, context)
        })

    }
}