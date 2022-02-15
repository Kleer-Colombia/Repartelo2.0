<template>
    <div class="button-container">
    <el-button type="primary" @click="dialogFormVisible = true">Actualizar objetivo</el-button>

        <el-dialog :title="'Actualizar objetivo anual'" :visible.sync="dialogFormVisible">
            <el-form label-width="150px">
            <el-form-item label="Monto">
                <input-money name="amount" :format="'income'" v-model="objectiveInfo.amount"></input-money>
            </el-form-item>
            </el-form>
            <el-col :offset="4">
                <h5>Porcentaje de saldo inicial</h5>
            </el-col>
            <el-col :span="2" :offset="4" style="padding-top: 10px; text-align: center">
                
					{{percentageSelector.min}}%
			</el-col>
			<el-col :span="10">
				<el-slider
								v-model="objectiveInfo.percentage"
								:max="percentageSelector.max"
								:min="percentageSelector.min"
								>
				</el-slider>

			</el-col>
			<el-col :span="2" style="padding-top: 10px; text-align: center">
					{{percentageSelector.max}}%
			</el-col>
            
            
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
                    percentage: 0
                },
                percentageSelector: {
                    max: 100,
                    min: 0,
                },
            }
        },
    methods: {
        addTax () {
            DynamicReportConnector.addObjective(this, {objective: this.objectiveInfo, percentage: this.objectiveInfo.percentage})
        },
        closeDialog (format) {
            if (format) {
                this.objectiveInfo = {
                    amount: '',
                    percentage: 0,
                }
            }
            this.dialogFormVisible = false
        },
    }
}
</script>

<style>
.button-container{
    display: flex;
    justify-content: flex-end;
}
</style>
