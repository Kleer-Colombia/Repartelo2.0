<template>
  <div>
    <!-- <el-row>
      <el-col :span="20" :offset="2">
        <el-tabs v-model="activeTab" style="margin-bottom: 30px;">
          <el-tab-pane v-for="year in tax.years" :key="year.year"
                      v-bind:label="year.year" v-bind:name="year.year">
            <taxes-detail v-bind:tax="tax" v-bind:taxDetails="year.taxDetails" v-bind:taxYear="year.year"/>
          </el-tab-pane>
        </el-tabs>
      </el-col>
    </el-row> -->
    
    <!-- taxes detail by year disable -->
    <el-row>
      <!-- -*----------------------------------------------------- -->
      <el-row :gutter="20">
        <el-col :span="5">
            <div class="grid-content">
                <h2>{{ tax.name }}</h2>
            </div>
        </el-col>
        <el-col :span="5">
            <div class="grid-content">
                <h3>Egresos: <br> <span v-html="addColorToValue(tax.header.egresos, 'egresos')"></span></h3>
            </div>
        </el-col>
        <el-col :span="5">
            <div class="grid-content">
                <h3>Ingresos: <br> <span v-html="addColorToValue(tax.header.ingresos, 'ingresos')"></span></h3>
            </div>
        </el-col>
        <el-col :span="5">
            <div class="grid-content">
                <h3>Total: <br> <span v-html="addColorToValue(tax.header.total, 'total')"></span></h3>
            </div>
        </el-col>
        <el-col :span="4">
        </el-col>
          <add-taxes-button @refresh="updateTax" style="float: right;" :tax="tax"/>
        </el-col>
      </el-row> 

      <el-row>
        <el-table
        :data="tax.months"
        style="width: 100%">
        <el-table-column id="detail" type="expand">
          <template slot-scope="props">
              <el-table
                :show-header="false"
                :data="props.row.detalles"
                style="width: 100%">
                <el-table-column
                  label="Fecha"
                  prop="date"
                  min-width="60">
                </el-table-column>
                <el-table-column
                        label="Monto"
                        prop="amount"
                        min-width="60">
                  <template slot-scope="scope">
                    <span v-html="addColorToValue(scope.row.amount, 'ID')"></span>
                  </template>
                </el-table-column>
                <el-table-column
                        label="Descripción"
                        prop="balance"
                        min-width="180">
                  <template slot-scope="scope">
                    <span>
                        <span v-html="getDescription(scope.row)"></span>
                    </span>
                  </template>
                </el-table-column>

                <el-table-column
                        label="Balance"
                        prop="balance">
          
                  <template slot-scope="scope">
                  <div v-if="hasBalance(scope.row)">
                    <router-link class="el-button el-button--text" :to="'/balance/'+ scope.row.balance.id ">
                      Balance {{scope.row.balance.id}}</router-link>
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

      <!-- ---------------------------------------------------------- -->
    </el-row>
  </div>
	
	
  

</template>

<script>
  import TaxesDetail from './TaxesDetail.vue'
  import util from '../../model/util'
  import AddTaxesButton from './AddTaxesButton.vue'
  import taxesConnector from '../../model/taxes_connector'

  export default {
    name: 'Taxes',
    components: {
    TaxesDetail,
    AddTaxesButton
},
    props: {
      tax: {
        type: Object,
        default: ''
      },
      updateTax: Function
    },
    data () {
      return {
        taxes: [],
        activeTab: ''
      }
    },
    mounted () {
      this.getCurrentYear()
    },
    methods: {
      getCurrentYear () {
	      this.activeTab = new Date().getFullYear()+''
      },
      addColorToValue (value, id) {
        return util.colorValue(value, id)
      },
      routeTo (route) {
        router.push(route)
      },
      
      getDescription (taxDetail) {
        // Cada parte se escapa por separado; los <br> los pone el código.
        if (!this.hasBalance(taxDetail)) {
          return util.linkify(taxDetail.concept)
        }
        const b = taxDetail.balance
        return [b.client, b.project, b.description].map(t => util.linkify(t)).join('<br>')
      },
      hasBalance (taxDetail) {
        return taxDetail.balance !== undefined
      }
    }
  }
</script>

<style scoped>

</style>
