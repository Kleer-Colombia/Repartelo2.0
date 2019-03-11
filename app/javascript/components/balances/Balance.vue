<template>
  <safe-body tittle="Módulo de Balances">
    <el-row :gutter="20">
      <el-col :span="20" :offset="2">
        <el-row :gutter="20">
          <el-col :span="10" :offset="2">
            <el-input name="client"
                      v-model="filters.keyword"
                      @change="filter()">
              <template slot="prepend">Filtrar balances</template>
            </el-input>
          </el-col>
          <el-col :span="8" style="padding-top: 10px;">
            <el-radio v-model="filters.active" label="client">Cliente</el-radio>
            <el-radio v-model="filters.active" label="project">Proyecto</el-radio>
            <el-radio v-model="filters.active" label="description">Descripción</el-radio>
          </el-col>
          <el-col :span="4">
            <el-button :plain="true" type="primary" @click="newBalance()">Nuevo</el-button>
          </el-col>
        </el-row>
      </el-col>
      <el-col :span="20" :offset="2">
        <br>
        <el-table :id='balances'
                  :data="filteredBalances"
                  border
                  :default-sort="{prop: 'date', order: 'descending'}"
                  style="width: 100%"
                  :row-class-name="setClassName">
          <el-table-column
                  prop="date"
                  label="Fecha"
                  min-width="80"
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
                  min-width="120"
                  sortable>
            <template slot-scope="scope">
              <span :id="'client'+scope.row.id">
                {{ scope.row.client }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
                  prop="project"
                  label="Proyecto"
                  min-width="300"
          >
            <template slot-scope="scope">
              <span :id="'project'+scope.row.id">
                {{ scope.row.project }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
                  prop="description"
                  label="Descripción"
                  min-width="300"
          >
            <template slot-scope="scope">
              <span :id="'description'+scope.row.id">
                {{ scope.row.description }}
              </span>
            </template>
          </el-table-column>
          <el-table-column
                  label="Opciones"
                  min-width="80">
            <template slot-scope="scope">
              <router-link class="el-button el-button--text" :to="'/balance/'+ scope.row.id ">Editar</router-link>
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
    data() {
      return {
        filters: {
          keyword: "",
          active: "cliente"
        },
        balances: [],
        filteredBalances: []
      }
    },
    created: function () {
      balanceConnector.findBalances(this)
    },
    methods: {
      newBalance() {
        router.push('/balance/new')
      },
      filter() {
        this.filteredBalances = this.balances.filter
        (balance => balance[this.filters.active].includes(this.filters.keyword))
      },
      setClassName({row, rowIndex}) {
        if (row.editable) {
          return 'normal-row'
        } else {
          return 'success-row'
        }
      }
    }
  }
</script>
