<template>

<el-main>
    <el-row :gutter="20">
      <el-col :span="5">
          <div class="grid-content">
              <h2>Clearings de {{ country.name }}</h2>
          </div>
      </el-col>
      <el-col :span="5">
          <div class="grid-content">
              <h3>Egresos: <br> <span v-html="addColorToValue(clearing.egresos, 'egresos')"></span></h3>
          </div>
      </el-col>
      <el-col :span="5">
          <div class="grid-content">
              <h3>Ingresos: <br> <span v-html="addColorToValue(clearing.ingresos, 'ingresos')"></span></h3>
          </div>
      </el-col>
      <el-col :span="5">
          <div class="grid-content">
              <h3>Total: <br> <span v-html="addColorToValue(clearing.total, 'total')"></span></h3>
          </div>
      </el-col>
      <el-col :span="4">
        <add-clearing-button @refresh="updateClearing" style="float: right;"/>
      </el-col>
    </el-row>

  <el-row>
    <el-table
    :data="clearing.meses"
    style="width: 100%">
    <el-table-column id="detail" type="expand">
      <template slot-scope="props">
          <el-table
            :show-header="false"
            :data="props.row.detalles"
            style="width: 100%">
            <el-table-column
              prop="fecha"
              min-width="30"
            >
            </el-table-column>
            <el-table-column
              prop="concepto"
              min-width="130"
            >
            </el-table-column>
            <el-table-column
              prop="amount"
              min-width="40">
                <template slot-scope="scope">
                  <div v-if="(scope.row.ingreso > 0)">
                    <span v-html="addColorToValue(scope.row.ingreso, 'ID')"></span>
                  </div>
                  <div v-else>
                    <span v-html="addColorToValue(scope.row.egreso, 'ID')"></span>
                  </div>
                </template>
            </el-table-column>
            <el-table-column
              prop="extKleerer"
              min-width="60"/>
            <el-table-column
              prop="referencia"
              min-width="100">
              <template slot-scope="scope">
                  <div v-if="scope.row.reference.includes('balance')">
                    <el-button @click="routeTo(scope.row.reference)" type="primary" icon="el-icon-zoom-in" round>Ver detalles</el-button>
                  </div>
                </template> 
            </el-table-column>
          </el-table>
      </template>
    </el-table-column>
    <el-table-column
      label="Mes"
      prop="fecha">
    </el-table-column>
    <el-table-column
      label="Egresos"
      prop="egresos">
        <template slot-scope="scope">
          <span v-html="addColorToValue(scope.row.egresos, 'ID')"></span>
        </template>
    </el-table-column>
    <el-table-column
      label="Ingresos"
      prop="ingresos">
        <template slot-scope="scope">
          <span v-html="addColorToValue(scope.row.ingresos, 'ID')"></span>
        </template>
    </el-table-column>
    <el-table-column
      label="Total mes"
      prop="total">
      <template slot-scope="scope">
        <span v-html="addColorToValue(scope.row.total, 'ID')"></span>
      </template>
    </el-table-column>
    <el-table-column
      label="Saldo"
      prop="saldo_acumulado">
      <template slot-scope="scope">
        <span v-html="addColorToValue(scope.row.saldo_acumulado, 'ID')"></span>
      </template>
    </el-table-column>
  </el-table>
  </el-row>
</el-main>

</template>

<style>
    .el-table, .el-table__expanded-cell {
        padding-right: 0 !important;
        padding-top: 0 !important;
        padding-bottom: 0 !important;
    }
</style>

<script>

  import util from '../../model/util'
  import router from '../../router'
  import clearingConnector from '../../model/clearing_connector'
  import AddClearingButton from './AddClearingButton.vue'


  export default {
    components: {
      AddClearingButton
    },
    props: {
      country: {
        type: Object,
        default: ''
      }
    },
    data () {
      return {
        clearing: {}
      }
    },
    created: function () {
      clearingConnector.find(this, this.country.id)
      //TODO: crear peticion para cargar clearings por pais
    },
    methods: {
      addColorToValue (value, id) {
        var color = 'black'
        if (value) {
          if (Number(value) < 0) {
            color = 'red'
          } else {
            color = 'green'
          }
          value = util.formatPrice(value)
        }
        return '<span style="color:' + color + '" id="' + id + '">' +
          value +
          '</span>'
      },
      updateClearing () {
        clearingConnector.find(this, this.country.id)
      },
      routeTo (route) {
        router.push(route)
      },
      formatReference (reference) {
        if (util.validURL(reference)) {
          return 'Referencia: <a target="_blank" href="' + reference + '"> aquí </a>'
        } else {
          return '<span>Ref: ' + reference + '</span>'
        }
      }
    }
  }
  </script>
