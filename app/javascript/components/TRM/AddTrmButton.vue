<template>
    <el-main>
    <el-button type="primary" @click="dialogFormVisible = true">Agregar USD TRM</el-button>

    <el-dialog :title="'Cargar nuevo TRM'" :visible.sync="dialogFormVisible">
        <el-form label-width="220px">
            <el-form-item label="Tasa">
                <el-input-number 
                    class="input-number"
                    v-model="trmInfo.rate"
                    :min="1"
                    :precision="2"
                    :step="0.01">
                </el-input-number>
            </el-form-item>
            <el-form-item label="Mes">
                <el-date-picker
                    v-model="trmInfo.date"
                    type="month"
                    v-bind:id="'tax_date'"
                    placeholder="Impuesto"
                    :picker-options="startDatePicker"
                    >
                    
                </el-date-picker>
            </el-form-item>
        
        </el-form>
        <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cancelar</el-button>
            <el-button type="primary" @click="addTRM()">Guardar</el-button>
        </span>
    </el-dialog>
    </el-main>
</template>


<script>
import reportConnector from '../../model/report_connector'

export default {
    data () {
        return {
            dialogFormVisible: false,
            trmInfo: {
                date: null,
                rate: 0,
                currency: 'USD',
            },
            startDatePicker: {
                disabledDate(time) {
                    return time.getTime() <= new Date(2022,4,1).getTime()
                }
            },
        }
    },
    methods: {
        addTRM () {
            // console.log(this.trmInfo)
            reportConnector.addTRM(this, {trm: this.trmInfo})
        },
        closeDialog (format) {
            if (format) {
            this.trmInfo = {
                date: null,
                rate: 0,
                currency: 'USD',
            }
            }
            this.dialogFormVisible = false
        }
    }
}
</script>

<style>
.el-input__inner{
    width: 100% !important;
}
</style>
