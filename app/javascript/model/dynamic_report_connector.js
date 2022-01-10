import axios from 'axios'
import util from './util'

const API_URL = util.apiUrl()
const kleerCoURL = `${API_URL}/objectives/reports`
const OBJECTIVES_URL = `${API_URL}/objectives`

export default {
    getData(context, nextFunction) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
                method: 'get',
                url: kleerCoURL
            })
            .then(response => {
                context.kleerCo = response.data.response.total
                context.kleerers = response.data.response.kleerers
                context.objectives = response.data.response.objectives
                if (nextFunction) {
                    console.log(response.data.response)
                    nextFunction(context)
                }
            })
            // .catch(error => {
            //     util.processErrorMsgs(error)
            // })
    },

    addObjective(context, objective) {
        axios.defaults.headers.common['Authorization'] = util.getAuthHeader()
        axios({
            method: 'post',
            url: OBJECTIVES_URL,
            data: objective
        }).then(response => {
            if (response.data.response) {
                // context.closeDialog(true)
                context.$message({
                    type: 'success',
                    message: 'Registro agregado exitosamente'
                })
                context.$emit('refresh')
            }
        }).catch(error => {
            console.log(error)
            util.processErrorMsgs(error, context)
        })
    }
}