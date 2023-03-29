<template>
    <div class="button-container">
    <el-button type="primary" @click="dialogFormVisible = true">Historico objetivos</el-button>

        <el-dialog :title="'Historico de objetivos'" :visible.sync="dialogFormVisible">
            <el-table 
                :id="objectives"
                :data="showObjectives()"
                border
                style="width: 100%">
                <el-table-column
                    prop="created_at"
                    label="Fecha">
                </el-table-column>
                <el-table-column
                    prop="amount"
                    label="Monto">
                </el-table-column>
            </el-table>
        </el-dialog>
    </div>
</template>


<script>

import InputMoney from '../base/InputMoney.vue'
import DynamicReportConnector from "../../model/dynamic_report_connector";
import util from '../../model/util';

export default {
    props:{
        objectives: {
            type: Array,
            default: ''
        },
        year: {
            type: Number,
            default: ''
        }
    },
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
        showObjectives(){
            console.log("objetivos")
            console.log(this.objectives)
            return this.objectives
            .map(objective => {
                return {
                    created_at: objective.created_at.substr(0,10),
                    amount: util.formatPrice(objective.amount)
                }
            })
        }
    }
}
</script>

<style>
.button-container{
    display: flex;
    justify-content: flex-end;
    margin-top: 5px
}
</style>
