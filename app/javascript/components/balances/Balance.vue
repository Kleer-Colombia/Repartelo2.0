<template>
  <safe-body tittle="Módulo de Balances">
    <el-row :gutter="20">
      <el-col :span="20" :offset="2">
        <el-row :gutter="20">
          
          <el-col :span="9" style="padding-top: 10px;">
	          <el-radio-group v-model="filters.active" @change="filter()">
		          <el-radio label="client">Cliente</el-radio>
		          <el-radio label="project">Proyecto</el-radio>
		          <el-radio label="description">Descripción</el-radio>
		          <el-radio label="id">Id</el-radio>
	          </el-radio-group>
           
          </el-col>
          <el-col :span="9">
            <el-input name="client"
                      v-model="filters.keyword"
                      @change="filter()">
              <template slot="prepend">Filtrar balances</template>
            </el-input>
          </el-col>
          <el-col :span="6">
            <el-checkbox :indeterminate="showing.isIndeterminate" v-model="showing.checkAll"
                         @change="handleCheckAllChange">Todos</el-checkbox>
            <div style="margin: 15px 0;"></div>
            <el-checkbox-group v-model="showing.checkedBalances" @change="handleCheckedBalancesChange">
              <el-checkbox v-for="status in showing.show" :label="status" :key="status">{{status}}</el-checkbox>
            </el-checkbox-group>
          </el-col>
        </el-row>
        <el-row>
          <el-button :plain="true" type="primary" @click="newBalance()">Nuevo</el-button>
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
                  prop="id"
                  label="Balance"
                  min-width="80"
                  sortable>
            <template slot-scope="scope">
              <span :id="'id-'+scope.row.id">
                {{ scope.row.id }}
              </span>
            </template>
          </el-table-column>
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
                  min-width="270"
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
                  min-width="270"
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
  const showOptions = ['Abiertos', 'Cerrados']

export default {
  
    components: {
      SafeBody
    },
    data () {
      return {
        filters: {
          keyword: '',
          active: 'client',
          showEditable: {Abiertos: true, Cerrados: false}
        },
        showing: {
          checkAll: false,
          checkedBalances: ['Abiertos', 'Cerrados'],
          show: showOptions,
          isIndeterminate: true
        },
        balances: [],
        filteredBalances: [],
        kleerers: []
      }
    },
    created: function () {
      balanceConnector.findBalances(this)
    },
    methods: {
      newBalance () {
        router.push('/balance/new')
      },
      filter () {
        if (this.showing.checkedBalances.length === 0) {
          this.filteredBalances = []
        } else if (this.showing.checkedBalances.length === 2) {
          this.filteredBalances = this.balances.filter(balance =>
            balance[this.filters.active].toString().toLowerCase().includes(this.filters.keyword.toString().toLowerCase()))
        } else {
          let editableFilter = this.filters.showEditable[this.showing.checkedBalances[0]]
          this.filteredBalances = this.balances.filter(balance =>
            balance[this.filters.active].toString().toLowerCase().includes(this.filters.keyword.toString().toLowerCase()) &&
          balance.editable === editableFilter)
        }
      },
      setClassName ({row, rowIndex}) {
        if (row.editable) {
          return 'normal-row'
        } else {
          return 'success-row'
        }
      },
      handleCheckAllChange (val) {
        this.showing.checkedBalances = val ? this.showing.show : []
        this.isIndeterminate = false
        this.filter()
      },
      handleCheckedBalancesChange (value) {
        let length = value.length ? value.length : 0
        let checkedCount = length
        this.showing.checkAll = checkedCount === this.showing.show.length
        this.showing.isIndeterminate = checkedCount > 0 && checkedCount < this.showing.show.length
        this.filter()
      }
    }
  }
</script>
