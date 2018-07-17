<template>

<el-main>
    <el-row :gutter="20">
      <el-col :span="6">
          <div class="grid-content">
              <h2>Saldos de {{ kleerer.name }}</h2>
          </div>
      </el-col>
      <el-col :span="6">
          <div class="grid-content">
              <h3>Egresos: <br> <span v-html="addColorToValue(saldo.egresos, 'egresos')"></span></h3>
          </div>
      </el-col>
      <el-col :span="6">
          <div class="grid-content">
              <h3>Ingresos: <br> <span v-html="addColorToValue(saldo.ingresos, 'ingresos')"></span></h3>
          </div>
      </el-col>
      <el-col :span="6">
          <div class="grid-content">
              <h3>Total: <br> <span v-html="addColorToValue(saldo.total, 'total')"></span></h3>
          </div>
      </el-col>
    </el-row>
  <el-row>
    <el-table
    :data="saldo.meses"
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
              prop="egreso"
              min-width="70">
                <template slot-scope="scope">
                  <span v-html="addColorToValue(scope.row.egreso, 'ID')"></span>
                </template>
            </el-table-column>
            <el-table-column
              prop="ingreso"
              min-width="70">
                <template slot-scope="scope">
                  <span v-html="addColorToValue(scope.row.ingreso, 'ID')"></span>
                </template>
            </el-table-column>
            <el-table-column
              prop="referencia"
              min-width="100">
              <template slot-scope="scope">
                  <div v-if="scope.row.referencia.includes('balance')">
                    <el-button @click="routeTo(scope.row.referencia)" type="primary" icon="el-icon-zoom-in" round>Ver detalles</el-button>
                  </div>
                  <div v-else>
                      <span v-html="formatReference(scope.row.referencia)"></span>
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
      label="Total"
      prop="total">
      <template slot-scope="scope">
        <span v-html="addColorToValue(scope.row.total, 'ID')"></span>
      </template>
    </el-table-column>
  </el-table>
  </el-row>
  <el-row>
    <add-saldos-button @refresh="updatesaldo" style="float: right;" :kleerer="kleerer"/>
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
  import saldosConnector from '../../model/saldos_connector'
  import AddSaldosButton from './AddSaldosButton.vue'

  export default {
    components: {
      AddSaldosButton
    },
    props: {
      kleerer: {
        type: Object,
        default: ''
      }
    },
    data () {
      return {
        saldo: {}
      }
    },
    created: function () {
      saldosConnector.find(this, this.kleerer.id)
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
      updatesaldo () {
        saldosConnector.find(this, this.kleerer.id)
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
