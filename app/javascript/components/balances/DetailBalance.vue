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
  <el-row id="row-money">
      <el-col :span="6">
          <incomes-admin v-model="incomes.totalIncomes" :editable="balance.editable" :allIncomes="incomes.realIncomes"/>

          <expenses-admin v-model="expenses.totalExpenses" :editable="balance.editable" :allExpenses="expenses.realExpenses"/>
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
import IncomesAdmin from "./IncomesAdmin"
import ExpensesAdmin from "./ExpensesAdmin"

export default {
  components: {
    IncomesAdmin,
    ExpensesAdmin,
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
        totalIncomes: 0
      },
      expenses: {
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
