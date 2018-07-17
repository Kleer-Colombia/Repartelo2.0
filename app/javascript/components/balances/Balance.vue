<template>
  <safe-body tittle="Módulo de Balances">
    <el-row :gutter="20">
    <el-col :span="20" :offset="2">
      <div class="grid-content"></div>
     
          <el-button  :plain="true" type="primary" @click="newBalance()">Nuevo</el-button>
    </el-col>
    <el-col :span="20" :offset="2">
      <br>
       <el-table :id='balances'
          :data="balances"
          border
          :default-sort = "{prop: 'date', order: 'descending'}"
          style="width: 100%"
          :row-class-name="setClassName">
          <el-table-column
            prop="date"
            label="Fecha"
            min-width="120"
          sortable>
            <template slot-scope="scope">
              <span :id="'date'+scope.row.id">
                {{ scope.row.date }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
            prop="client"
            label="Cliente"
            min-width="150"
            sortable>
            <template slot-scope="scope">
              <span :id="'client'+scope.row.id">
                {{ scope.row.client }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
            prop="description"
            label="Descripción"
            min-width="650"
            >
            <template slot-scope="scope">
              <span :id="'description'+scope.row.id">
                {{ scope.row.description }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
            label="Opciones"
            min-width="120">
            <template slot-scope="scope">
              <el-button type="text" @click='viewBalance(scope.row.id)'>Editar</el-button>
            </template>
          </el-table-column>
        </el-table>
    </el-col>
  </el-row>
  </safe-body>
</template>

<style>
    .el-table .normal-row {
        background: white;
    }

    .el-table .success-row {
        background: #f0f9eb;
    }

    .el-table__header {
        margin-bottom: 0px;
    }
</style>

<script>

import router from '../../router'
import balanceConnector from '../../model/balance_connector'
import SafeBody from '../base/SafeBody.vue'

export default {
  components: {
    SafeBody
  },
  data () {
    return {
      balances: []
    }
  },
  created: function () {
    balanceConnector.findBalances(this)
  },
  methods: {
    newBalance () {
      router.push('/balance/new')
    },
    viewBalance (id) {
      router.push('/balance/' + id)
    },
      setClassName({row, rowIndex}) {
          if (row.editable) {
              return 'normal-row';
          } else {
              return 'success-row';
          }
          return '';
      }
  }
}
</script>
