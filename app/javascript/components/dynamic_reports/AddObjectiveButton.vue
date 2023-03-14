<template>
    <div class="button-container">
    <el-button type="primary" @click="dialogFormVisible = true">Actualizar objetivo</el-button>

        <el-dialog :title="'Actualizar objetivo anual'" :visible.sync="dialogFormVisible">
            <el-form label-width="150px">
            <el-form-item label="Monto">
                <input-money name="amount" :format="'income'" v-model="objectiveInfo.amount"></input-money>
            </el-form-item>
            </el-form>
            <el-row>
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
            </el-row>
            <h4 style="margin: 50px 10%">Seleccione los kleerers que participarán este año</h4>

            <el-row :gutter="10" v-for="kleerer in allKleerers" :key="kleerer.id"
                        :id="'percentage_' + kleerer.name">
                <el-col :span="6" :offset="3">
                    <el-checkbox-button
                            v-model="kleerer.selected"
                            :label="kleerer.id"
                            :key="kleerer.name"
                            :id="'check' + kleerer.name"
                            style="color: blue"
                            @change="selectKleerer(kleerer)">
                        <span>{{ kleerer.name }}</span>
                    </el-checkbox-button>
                </el-col>
                <el-col :offset="0" :span="6">  
                    <el-checkbox-button
                        v-model="kleerer.hasCustomObjective"
                        :key="kleerer.id"
                        :id="'check-value' + kleerer.name"
                        :disabled="!kleerer.selected"
                        @change="selectKleerer(kleerer)">
                        <span>Objetivo especifico</span>
                    </el-checkbox-button>
                </el-col>
                <el-col :offset="0" :span="6">
                    <div v-show="kleerer.hasCustomObjective">
                        <el-input-number 
                            v-model="kleerer.customObjective" 
                            :name="'inputObjective' + kleerer.name" 
                            :min="0">
                        </el-input-number>
                    </div>
                </el-col>
            </el-row>
            
        
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
    props:{
        allKleerers: [],
    },
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
            DynamicReportConnector.addObjective(this, {objective: this.objectiveInfo, kleerers: this.sendKleerers()})
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
        selectKleerer (kleerer) {
            this.$emit('input', null)
            this.$forceUpdate()
        },
        sendKleerers(){
            return this.allKleerers.filter(kleerer => kleerer.selected)
                                    .map(kleerer => {
                                        return {
                                            id: kleerer.id,
                                            hasCustomObjective: kleerer.hasCustomObjective,
                                            customObjective: kleerer.customObjective
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
}

.el-checkbox-button__inner{
    width: 150px !important;
}
</style>
