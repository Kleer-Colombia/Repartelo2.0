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
      routeTo (route) {
        router.push(route)
      },
      
      getDescription (taxDetail) {
        let description = ''
        if (!this.hasBalance(taxDetail)) {
          description = taxDetail.concept
        } else {
          description = taxDetail.balance.client + '<br>' + taxDetail.balance.project + '<br>' + taxDetail.balance.description
        }
        description = this.urlify(description)
        return description
      },
      urlify (text) {
        let urlRegex = /((?:(http|https|Http|Https|rtsp|Rtsp):\/\/(?:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,64}(?:\:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,25})?\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\:\d{1,5})?)(\/(?:(?:[a-zA-Z0-9\;\/\?\:\@\&\=\#\~\-\.\+\!\*\'\(\)\,\_])|(?:\%[a-fA-F0-9]{2}))*)?(?:\b|$)/gi
        return text.replace(urlRegex, function (url) {
          return `<a target="_blank" href="${url}">${url}</a>`
        })
      },
      hasBalance (taxDetail) {
        return taxDetail.balance !== undefined
      }
    }
  }
</script>

<style scoped>

</style>
