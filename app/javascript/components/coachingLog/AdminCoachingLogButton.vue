<template>
    <el-main>
        <el-container>
            <el-main>
                <el-row>
                    <el-col :span="10">
                        <h3 class="center">Total de sessiones {{summary.totalcs}}</h3>
                    </el-col>
                    <el-col :span="12">
                        <el-button class="center" type="primary" id='admin-coaching' @click="openDialog()">Administrar sessiones de coaching
                        </el-button>
                    </el-col>
                </el-row>
                <el-row>
                    <el-table :data="summary.distribution" size="small">
                        <el-table-column property="kleerer" label="Kleerer"></el-table-column>
                        <el-table-column property="sessions" label="Sesiones">
                            <template slot-scope="scope">
                                <span :id="scope.row.kleerer+'_sessions'">{{scope.row.sessions}}</span>
                            </template>
                        </el-table-column>
                        <el-table-column property="percentage" label="Porcentaje">
                            <template slot-scope="scope">
                                <b :id="scope.row.kleerer+'_percentage'">{{scope.row.percentage}}%</b>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-row>
            </el-main>
            <el-footer>
                <el-row>
                    <el-col :span="8" :offset="8">
                        <el-button type="success" id="Distribuir" @click="distribute()"
                                   :disabled="!editable">Distribuir
                        </el-button>
                    </el-col>
                </el-row>

            </el-footer>
        </el-container>


        <el-dialog title="Administrar log de coaching" :visible.sync="adminVisible">
            <el-row>
                <coaching-log-form :editable="editable" v-on:update="updateList" :balance-id="balanceId"></coaching-log-form>
            </el-row>

            <el-row>
                <el-table id='tableCoachingSessions' :data="sessions" height="250" size="small">
                    <el-table-column property="date" label="Fecha" width="150"></el-table-column>
                    <el-table-column property="kleerers" label="Kleerers" width="200"></el-table-column>
                    <el-table-column property="description" label="Descripción"></el-table-column>
                    <el-table-column label="opciones">
                        <template slot-scope="scope">
                            <el-button :disabled="!editable" type="text" @click='deleteCoachingSession(scope.row.id)' icon="el-icon-error">Eliminar</el-button>
                        </template>
                    </el-table-column>
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
  import balanceConnector from '../../model/balance_connector'

  export default {
    components: {CoachingLogForm},
    name: 'admin-coaching-log',
    props: {
      balanceId: {
        type: [String, Number]
      },
      editable: {
        type: [Boolean],
        default: true
      }
    },
    data () {
      return {
        adminVisible: false,
        isNeededUpdatePercentage: false,
        sessions: [{
          id: '',
          date: '',
          kleerers: '',
          description: ''
        }],
        summary: {
          totalcs: 0,
          distribution: [{kleerer: '', sessions: 0, percentage: 0}, {kleerer: '', sessions: 0, percentage: 0}]
        }
      }
    },
    created: function () {
      this.summarize(false)
    },
    methods: {
      closeDialog () {
        this.summarize(this.isNeededUpdatePercentage)
        this.adminVisible = false
      },
      openDialog () {
        this.updateList()
        this.adminVisible = true
      },
      updateList () {
        this.isNeededUpdatePercentage = true
        coachingSessionConnector.find(this, this.balanceId)
      },
      deleteCoachingSession (id) {
        coachingSessionConnector.delete(this, this.balanceId, id)
      },
      summarize (isNeededUpdatePercentage) {
        if (isNeededUpdatePercentage){
          coachingSessionConnector.summary(this, this.$route.params.id,isNeededUpdatePercentage)
        }
      },
      distribute () {
        let data = {
          balanceId: this.$route.params.id
        }
        balanceConnector.distribute(this, data)
      }
    }
  }

</script>

<style scoped>
    .center {
        text-align: center;
    }

</style>
