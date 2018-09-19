<template>
    <el-main>
        <el-button type="primary" id='admin-coaching' @click="adminVisible = true">Administrar sessiones de coaching
        </el-button>

        <el-dialog title="Administrar log de coaching" :visible.sync="adminVisible">
            <el-row>
                <coaching-log-form :balance-id="balanceId"></coaching-log-form>
            </el-row>

            <el-row>
                <el-table :data="sessions">
                    <el-table-column property="date" label="Fecha" width="150"></el-table-column>
                    <el-table-column property="kleerers" label="Kleerers" width="200"></el-table-column>
                    <el-table-column property="description" label="Descripción"></el-table-column>
                </el-table>
            </el-row>

            <span slot="footer" class="dialog-footer">
                <el-button @click="closeDialog(false)">Cerrar</el-button>
            </span>
        </el-dialog>
    </el-main>
</template>

<script>
  import CoachingLogForm from './CoachingLogForm'

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
      closeDialog (format) {
        this.dialogFormVisible = false
      }
    }
  }

</script>

<style scoped>

</style>
