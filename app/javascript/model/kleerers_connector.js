import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const KLEERERS_URL = API_URL + '/kleerers'

export default {

    getKleerers(context, filter, actions = () => {}) {
        let url = KLEERERS_URL
        if (filter) {
            url += '/filter'
        }
        this.consult(context, url, actions)
    },

    consult(context, url, actions) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'get',
            url: url
        }).then(function(response) {
            context.kleerers = response.data.response
            actions()
        }).catch(function(error) {
            util.processErrorMsgs(error, context)
        })
    }
}