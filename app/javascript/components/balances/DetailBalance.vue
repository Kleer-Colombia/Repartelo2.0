<template>
  <safe-body>
      <el-row>
        <el-card class="box-card">
            
            <el-col :offset="2" :span="4">
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
        </el-card> 
  </el-row>
  <el-row>
      <el-col :span="6">
        <el-card class="box-card" :span="6">
            <div v-if="incomes.newIncome" slot="header" class="clearfix">

                <el-form label-position="left" label-width="100px">
      
                    <el-form-item label="Descripción">
                        <el-input name="incomeDescription" v-model="incomes.income.description"></el-input>
                    </el-form-item>
                    <el-form-item label="Monto">
                        <input-money name="incomeAmount" v-model="incomes.income.amount"></input-money>  
                    </el-form-item>
                    <el-form-item>
                        <el-button-group>
                            <el-button  :plain="true" type="danger" size="mini" icon="el-icon-error" @click="showIncome()"></el-button>
                            <el-button  id="saveIncome" type="primary" size="mini" icon="el-icon-success" @click="addIncome()"></el-button>
                        </el-button-group>
                    </el-form-item>
                </el-form>
            </div>
            <div v-else slot="header" class="clearfix">
                <el-button type="primary" id="nuevo ingreso" @click="showIncome()" :disabled="!balance.editable" > nuevo ingreso</el-button>
            </div>

            <div v-for="income in incomes.realIncomes" :key="income.amount" class="text item">
                <el-row>
                    <div style="float: left">
                        <el-button-group style="margin-right: 5px;" >
                            <el-button v-bind:id="'removeIncome'+income.amount" :disabled="!balance.editable" 
                            :plain="true" size="mini" type="text" icon="el-icon-remove-outline" @click="removeIncome(income.id)"></el-button>
                        </el-button-group>
                        <label>{{ income.description }}</label>
                    </div>
                    <label style="float: right;">{{ formatPrice(income.amount) }}</label>
                </el-row>
            </div>
   
        </el-card>
         <el-card class="box-card" :span="6">
          <div v-if="expenses.newExpense" slot="header" class="clearfix">
            <el-form label-position="left" label-width="100px">
             <el-form-item label="Descripción">
                <el-input name="expenseDescription" v-model="expenses.expense.description"></el-input>
              </el-form-item>
              <el-form-item label="Monto">
                <input-money name="expenseAmount" v-model="expenses.expense.amount"></input-money>  
              </el-form-item>
              <el-form-item>
                  <el-button-group>
                      <el-button :plain="true" type="danger" size="mini" icon="el-icon-error" @click="showExpense()"></el-button>
                      <el-button id="saveExpense" type="primary" size="mini" icon="el-icon-success" @click="addExpense()"></el-button>
                  </el-button-group>
              </el-form-item>
            </el-form>
          </div>
          <div v-else slot="header" class="clearfix">
            <el-button type="primary" id="nuevo egreso" @click="showExpense()" :disabled="!balance.editable">nuevo egreso</el-button>
          </div>

          <div v-for="expense in expenses.realExpenses" :key="expense.amount" class="text item">
            <el-row>
                <div style="float: left">
                    <el-button-group style="margin-right: 5px;" >
                        <el-button v-bind:id="'removeExpense'+expense.amount" :disabled="!balance.editable" :plain="true" size="mini" type="text" icon="el-icon-remove-outline" @click="removeExpense(expense.id)"></el-button>
                    </el-button-group>
                    <label>{{ expense.description }}</label>
                </div>
                <label style="float: right;">{{ formatPrice(expense.amount) }}</label>
              </el-row>
          </div>
        </el-card>
      </el-col>
      <el-col :span="18">
        <el-card class="box-card">
          <el-row :gutter="10">
            <el-col :span="8" :offset="1">
              <div class="grid-content"></div>
              
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
          <el-col :span="12" :offset="1">
                <br>
                    <el-row :gutter="10" v-for="kleerer in distribution.kleerers" :key="kleerer.id" :id="'percentage_' + kleerer.name">
                    <el-col :span="6">
                      <el-checkbox-button
                      v-model="kleerer.selected"
                      :label="kleerer.id" 
                      :key="kleerer.name"
                      :id="'check' + kleerer.name"
                      :disabled="!balance.editable"
                      @change="selectKleerer(kleerer)">
                        <span>{{ kleerer.name }}</span> - 
                        <span style="font-size: 12px">{{ kleerer.option }}</span>
                      </el-checkbox-button>
                    </el-col>
                     <el-col :offset="1" :span="8">
                       <div v-show="kleerer.selected">
                        <el-progress :percentage="kleerer.value" :stroke-width="15" style="margin-top: 12px;"></el-progress>
                      </div>
                    </el-col>
                    <el-col :offset="1" :span="4">
                        <div v-show="kleerer.selected">
                        <el-input @change="formatValue(kleerer,$event)" v-model="kleerer.value" 
                        :id="'inputPercentage' + kleerer.name" :disabled="!balance.editable">
                        </el-input>
                        </div>
                    </el-col>
                  </el-row>
          </el-col>
        </el-row>
        <el-row>
          <el-col :offset="8">
            <el-button type="success" id="Distribuir" @click="distribute()" :disabled="!balance.editable">Distribuir</el-button>
            <el-button type="danger" id="Borrar" @click="deleteBalance()" :disabled="!balance.editable">Borrar</el-button>
          </el-col>
        </el-row>
        <el-row v-if="distribution.result">  
          <el-row>
          <el-col :offset="2" :span="20">
            <el-table
            :data="distribution.result"
            border
            :default-sort = "{prop: 'date', order: 'descending'}"
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
            <el-button type="success" id="Enviar a saldos" @click="close()" :disabled="!balance.editable">Enviar a saldos</el-button>
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
  .money{
    width: 95%;
  }
  .el-checkbox-button__inner{
    width: 120px;
  }  
</style>
<script>

import balanceConnector from '../../model/balance_connector'
import dealer from '../../model/kleerers_distributions'
import util from '../../model/util'
import SafeBody from '../base/SafeBody.vue'
import InputMoney from '../base/InputMoney.vue'

export default {
  components: {
    SafeBody,
    InputMoney
  },
  name: 'detailBalance',
  data () {
    return {
      balance: {
        id: '',
        client: '',
        project: '',
        description: '',
        editable: true
      },
      distribution: {
        kleerers: [],
        result: '',
        percentageCached: []
      },
      incomes: {
        realIncomes: [],
        totalIncomes: 0,
        newIncome: false,
        income: {
          description: '',
          amount: ''
        }
      },
      expenses: {
        newExpense: false,
        expense: {
          description: '',
          amount: ''
        },
        realExpenses: [],
        totalExpenses: 0
      }
    }
  },
  created: function () {
    balanceConnector.findBalance(this, function (context) {
      balanceConnector.getKleerers(context, function (context) {
        context.updateKleerersSelecteds(context)
      })
    })
  },
  methods: {
    updateKleerersSelecteds (context) {
      var percentages = context.distribution.percentageCached
      var kleerers = context.distribution.kleerers
      for (var i = 0; i < percentages.length; i++) {
        for (var j = 0; j < kleerers.length; j++) {
          if (percentages[i].kleerer_id === kleerers[j].id) {
            kleerers[j].selected = true
            kleerers[j].value = parseFloat(percentages[i].value)
          }
        }
      }
    },
    showIncome () {
      this.incomes.newIncome = !this.incomes.newIncome
    },
    addIncome () {
      this.error = ''
      balanceConnector.addIncome(this, this.$route.params.id)
      this.incomes.newIncome = false
    },
    removeIncome (incomeId) {
      this.error = ''
      balanceConnector.removeIncome(this, this.$route.params.id, incomeId)
    },
    showExpense () {
      this.expenses.newExpense = !this.expenses.newExpense
    },
    addExpense () {
      this.error = ''
      balanceConnector.addExpense(this, this.$route.params.id)
      this.expenses.newExpense = false
    },
    removeExpense (expenseId) {
      this.error = ''
      balanceConnector.removeExpense(this, this.$route.params.id, expenseId)
    },
    selectKleerer (kleerer) {
      dealer.setPercentage(this.distribution.kleerers)
      this.updateKleerersPercentages()
      this.distribution.result = null
      this.$forceUpdate()
    },
    formatValue (kleerer, value) {
      if (kleerer.value >= 100) {
        kleerer.value = 100
      }
      if (kleerer.value < 0) {
        kleerer.value = 0
      }
      kleerer.value = Math.round(kleerer.value * 100) / 100
      this.updateKleerersPercentages()
      this.distribution.result = null
      this.$forceUpdate()
    },
    updateKleerersPercentages () {
      var kleerersSelected = dealer.prepareSelecteds(this.distribution.kleerers)
      balanceConnector.updateKleerersPercentages(this, this.$route.params.id, kleerersSelected)
    },
    formatPrice (value) {
      return util.formatPrice(value)
    },
    distribute () {
      if (dealer.areValidPercentage(this.distribution.kleerers)) {
        var data = {
          balanceId: this.$route.params.id
        }
        balanceConnector.distribute(this, data)
      } else {
        this.$message({
          type: 'error',
          message: 'la suma de los porcentajes de distribucion no suma 100, verificalo bien ;-)'
        })
      }
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
