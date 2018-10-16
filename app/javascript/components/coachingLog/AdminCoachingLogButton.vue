<template>
    <el-main>
        <el-button type="primary" id='admin-coaching' @click="openDialog()">Administrar sessiones de coaching
        </el-button>

        <el-dialog title="Administrar log de coaching" :visible.sync="adminVisible">
            <el-row>
                <coaching-log-form v-on:update="updateList" :balance-id="balanceId"></coaching-log-form>
            </el-row>

            <el-row>
                <el-table :data="sessions" height="350">
                    <el-table-column property="date" label="Fecha" width="150"></el-table-column>
                    <el-table-column property="kleerers" label="Kleerers" width="200"></el-table-column>
                    <el-table-column property="description" label="Descripción"></el-table-column>
                </el-table>
            </el-row>

            <span slot="footer" class="dialog-footer">
                <el-button @click="closeDialog()">Cerrar</el-button>
            </span>
        </el-dialog>
    </el-main>
</template>

<script>
  import CoachingLogForm from './CoachingLogForm'
  import coachingSessionConnector from '../../model/coaching_session_connector'

  export default {
    components: {CoachingLogForm},
    name: 'admin-coaching-log',
    props: {
      balanceId: {
        type: [String, Number]
      }
    },
    data () {
      return {
        adminVisible: false,
        sessions: [{
          date: '',
          kleerers: 'Yamit',
          description: 'prueba de log'
        }]
      }
    },
    methods: {
      closeDialog () {
        this.adminVisible = false
      },
      openDialog () {
        coachingSessionConnector.find(this, this.balanceId)
        this.adminVisible = true
      },
      updateList () {
        coachingSessionConnector.find(this, this.balanceId)
      }
    }
  }

</script>

<style scoped>

</style>
