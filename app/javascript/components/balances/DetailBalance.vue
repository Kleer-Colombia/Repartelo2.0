<template>
    <safe-body>
        <el-card class="box-card">
            <el-row>
                <el-col :offset="2" :span="2">
                    <div class="grid-content">
                        <p>ID: {{balance.id}}</p>
                    </div>
                </el-col>
                <el-col :span="4">
                    <div class="grid-content">
                        <p>Cliente: <span id="client">{{balance.client}}</span></p>
                    </div>
                </el-col>
                <el-col :span="4">
                    <div class="grid-content">
                        <p>Project: <span id="project">{{balance.project}}</span></p>
                    </div>
                </el-col>
                <el-col :span="4">
                    <div class="grid-content">
                        <p>Fecha: <span id="date">{{balance.date}}</span></p>
                    </div>
                </el-col>
                <el-col :span="4">
                    <div class="grid-content">
                        <p>Description: <span id="description">{{balance.description}}</span></p>
                    </div>
                </el-col>
                <el-col :offset="1" :span="2">
                    <el-button type="danger" id="Borrar" @click="deleteBalance()"
                               :disabled="!balance.editable">
                        Borrar
                    </el-button>
                </el-col>

            </el-row>
        </el-card>
        <el-row id="row-money">
            <el-col :span="6">
                <incomes-admin v-model="incomes.totalIncomes" :editable="balance.editable"
                               :allIncomes="incomes.realIncomes"/>
                <expenses-admin v-model="expenses.totalExpenses" :editable="balance.editable"
                                :allExpenses="expenses.realExpenses"/>
            </el-col>
            <el-col :span="18">
                <el-card class="box-card">
                    <el-row :gutter="10">
                        <el-col :span="8" :offset="1">
                            <el-table
                                    :data="summary()"
                                    border
                                    style="width: 100%">
                                <el-table-column
                                        prop="title"
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
                        </el-col>
                        <div v-if="balance.balance_type === 'standard' ">
                            <kleerers-distribution v-model="distribution.result" :editable="balance.editable"
                                                   :balancePercentages="distribution.balancePercentages"/>
                        </div>
                        <div v-else>
                            <coaching-distribution></coaching-distribution>
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
  import util from '../../model/util'
  import SafeBody from '../base/SafeBody.vue'
  import IncomesAdmin from './IncomesAdmin'
  import ExpensesAdmin from './ExpensesAdmin'
  import KleerersDistribution from './kleerersDistribution'
  import CoachingDistribution from './CoachingDistribution'

  export default {
    components: {
      CoachingDistribution,
      KleerersDistribution,
      IncomesAdmin,
      ExpensesAdmin,
      SafeBody
    },
    name: 'detailBalance',
    data () {
      return {
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
          realIncomes: [],
          totalIncomes: 0
        },
        expenses: {
          realExpenses: [],
          totalExpenses: 0
        }
      }
    },
    created: function () {
      balanceConnector.findBalance(this)
    },
    methods: {
      formatPrice (value) {
        return util.formatPrice(value)
      },
      close () {
        this.$confirm('Esta opcion envia la distribucion a saldos kleerers y hara que el balance no se pueda volver a editar, ¿Desea continuar?',
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
      deleteBalance () {
        this.$confirm('Esto borrara permanentemente todos los datos asociados a este balance, ¿Desea continuar?',
          'Cuidado!', {
            confirmButtonText: 'Aceptar',
            cancelButtonText: 'Cancelar',
            type: 'warning',
            center: true
          }).then(() => {
          balanceConnector.deleteBalance(this, this.$route.params.id)
        }).catch(() => {
          this.$message({
            type: 'info',
            message: 'Borrado cancelado'
          })
        })
      },
      summary () {
        return [
          {title: 'Ingresos', total: this.incomes.totalIncomes, id: 'totalIncomes'},
          {title: 'Egresos', total: this.expenses.totalExpenses, id: 'totalExpenses'},
          {title: 'Utilidad', total: this.incomes.totalIncomes - this.expenses.totalExpenses, id: 'totalProfit'}
        ]
      }
    }
  }
</script>
