<template>
    <div class="button-container">
    <el-button type="primary" @click="dialogFormVisible = true">Actualizar objetivo</el-button>

        <el-dialog :title="'Actualizar objetivo anual'" :visible.sync="dialogFormVisible">
            <el-form label-width="220px">
            <el-form-item label="Monto">
                <input-money name="amount" :format="'income'" v-model="objectiveInfo.amount"></input-money>
            </el-form-item>
            </el-form>
            <span slot="footer" class="dialog-footer">
                <el-button @click="closeDialog(false)">Cancelar</el-button>
                <el-button type="primary" @click="addTax()">Guardar</el-button>
            </span>
        </el-dialog>
    </div>
</template>


<script>

import InputMoney from '../base/InputMoney.vue'
import DynamicReportConnector from "../../model/dynamic_report_connector";

export default {
  components: { InputMoney },
    data () {
        return {
            format: 'expense',
            dialogFormVisible: false,
            objectiveInfo: {
                amount: 0,
            }
        }
    },
    methods: {
        addTax () {
            DynamicReportConnector.addObjective(this, {objective: this.objectiveInfo})
            console.log('enviar')
        },
        closeDialog (format) {
            if (format) {
                this.objectiveInfo = {
                    amount: '',
                }
            }
            this.dialogFormVisible = false
        }
    }
}
</script>

<style>
.button-container{
    display: flex;
    justify-content: flex-end;
}
</style>
