<template>
    <safe-body>
        <div v-loading="!loaded">
            <properties-balance :id="balance.id"
                                :client="balance.client"
                                :project="balance.project"
                                :description="balance.description"
                                :balance_type="balance.balance_type"
                                :retencion="balance.retencion"
                                :date="balance.date"
                                :editable="balance.editable"
            />
            <el-row id="row-money">
                <el-col :span="6">
                    <div v-if="checkFlag('balance-incomes')">
                        <incomes-admin v-on:updateTaxes="updateTaxes" :editable="balance.editable"
                                      :allIncomes="incomes.realIncomes"/>
                    </div>
                    <div v-if="checkFlag('balance-invoices')">
                    <invoice-selector v-on:updateTaxes="updateTaxes" :editable="balance.editable"
                                      :allIncomes="incomes.realIncomes"/>
                    </div>
                    <expenses-admin v-on:updateTaxes="updateTaxes" :editable="balance.editable"
                                    :allExpenses="expenses.realExpenses"/>
                </el-col>
                <el-col :span="18">
                    <el-card class="box-card">
                        <el-row :gutter="10">
                            <el-col :span="8" :offset="1">
                                <div v-if="showResume">
                                    <el-table
                                            :data="resume"
                                            border
                                            style="width: 100%">
                                        <el-table-column
                                                prop="tittle"
                                                label="">
                                        </el-table-column>
                                        <el-table-column
                                                prop="total"
                                                label="Totales">
                                            <template slot-scope="scope">
                                                <b>
                                                    <span :id="scope.row.id">
                                                      {{ formatPrice(scope.row.total) }}
                                                    </span>
                                                </b>
                                            </template>
                                        </el-table-column>
                                    </el-table>
                                </div>
                            </el-col>

                            <div v-if="balance.balance_type === 'coaching' ">
                                <admin-coaching-log v-model="distribution.result" :balanceId="balance.id"
                                                    :editable="balance.editable"
                                                    key="admin-coaching-log"></admin-coaching-log>
                            </div>
                            <div v-else>
                                <kleerers-distribution v-model="distribution.result" :editable="balance.editable"
                                                      :balancePercentages="distribution.balancePercentages"
                                                      key="kleerers-distribution"/>
                            </div>

                        </el-row>

                        <el-row v-if="distribution.result">
                            <el-row>
                                <el-col :offset="2" :span="20">
                                    <el-table
                                            :data="distribution.result"
                                            border
                                            :default-sort="{prop: 'date', order: 'descending'}"
                                            style="width: 100%">
                                        <el-table-column
                                                prop="kleerer"
                                                label="Nombre"
                                                sortable>
                                        </el-table-column>
                                        <el-table-column
                                                prop="amount"
                                                label="Monto">
                                            <template slot-scope="scope">
                  <span :id="'money'+scope.row.kleerer">
                    {{ formatPrice(scope.row.amount) }}
                  </span>
                                            </template>
                                        </el-table-column>
                                    </el-table>
                                </el-col>
                            </el-row>
                            <el-row>
                                <el-col :offset="8">
                                    <el-button type="success" id="Enviar a saldos" @click="close()"
                                              :disabled="!balance.editable">Enviar a saldos
                                    </el-button>
                                </el-col>
                            </el-row>
                        </el-row>
                    </el-card>
                </el-col>
            </el-row>
        </div>


    </safe-body>
</template>
<style>
    .box-card {
        margin-left: 10px;
        margin-right: 10px;
        margin-top: 10px;
    }

    .money {
        width: 95%;
    }

    .el-checkbox-button__inner {
        width: 120px;
    }
</style>
<script>

  import balanceConnector from '../../model/balance_connector'
  import propertiesBalance from './PropertiesBalance.vue'
  import util from '../../model/util'
  import SafeBody from '../base/SafeBody.vue'
  import IncomesAdmin from './IncomesAdmin'
  import ExpensesAdmin from './ExpensesAdmin'
  import KleerersDistribution from './kleerersDistribution'
  import AdminCoachingLog from '../coachingLog/AdminCoachingLogButton'
  import invoiceSelector from '../invoices/invoiceSelector'

  export default {
    components: {
      AdminCoachingLog,
      KleerersDistribution,
      IncomesAdmin,
      ExpensesAdmin,
      SafeBody,
      invoiceSelector,
      propertiesBalance
    },
    name: 'detailBalance',
    data () {
      return {
        loaded: false,
        showResume: true,
        balance: {
          id: '',
          client: '',
          project: '',
          description: '',
          editable: true,
          balance_type: ''
        },
        distribution: {
          result: '',
          balancePercentages: []
        },
        incomes: {
          realIncomes: []
        },
        expenses: {
          realExpenses: []
        },
        resume: []
      }
    },
    beforeCreate: function () {
      balanceConnector.findBalance(this, function (context) {
        context.loaded = true
      })
    },
    methods: {
      updateTaxes () {
        this.showResume = false
        this.distribution.result = false
        balanceConnector.updateTaxes(this, this.$route.params.id)
      },
      formatPrice (value) {
        return util.formatPrice(value)
      },
      close () {
        this.$confirm('Esta opcion envia la distribución a saldos kleerers y hara que el balance no se pueda volver a editar, ¿Desea continuar?',
          'Cuidado!', {
            confirmButtonText: 'Aceptar',
            cancelButtonText: 'Cancelar',
            type: 'warning',
            center: true
          }).then(() => {
            var data = {
              balanceId: this.$route.params.id
            }
            balanceConnector.close(this, data)
          }).catch(() => {
            this.$message({
              type: 'info',
              message: 'verificalo bien ;-)'
            })
          })
      },
      prepareResume (data) {
        let taxes = []
        Object.keys(data).map(function (objectKey, index) {
          let obj = {}
          obj['tittle'] = objectKey
          obj['total'] = data[objectKey]
          obj['id'] = 'money' + objectKey

          taxes.push(obj)
        })
        this.resume = taxes
        this.showResume = true
      },
      checkFlag (flag) {
        return util.checkFlag(flag)
      }
    }
  }
</script>
