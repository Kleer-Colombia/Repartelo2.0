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
                console.log('toda la respuesta')
                console.log(response.data.response)
                context.distributedObjectives = response.data.response.distributed_objectives
                context.allKleerers = response.data.response.all_kleerers.map(kleerer => {
                    kleerer.selected = false
                    kleerer.customObjective = 0
                    kleerer.hasCustomObjective = false

                    return kleerer
                })

                context.kleerCo = response.data.response.total
                    // context.kleerers = response.data.response.kleerers
                    // context.objectives = response.data.response.objectives

                // context.kleerersByYears = response.data.response.filtered_kleerers
                if (nextFunction) {

                    nextFunction(context)
                }
            })
            .catch(error => {
                util.processErrorMsgs(error)
            })
    },

    addObjective(context, objective) {
        console.log(objective)
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
            util.processErrorMsgs(error, context)
        })
    }
}