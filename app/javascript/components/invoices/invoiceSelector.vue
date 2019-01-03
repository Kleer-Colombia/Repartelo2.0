<template>
    <el-card class="box-card" :span="6">
        <div slot="header" class="clearfix">
            <el-button :disabled="!editable"
                       type="primary" id='get-invoices' @click="openDialog()">Buscar factura
            </el-button>
        </div>

        <el-row>
            <div v-for="income in realIncomes" :key="income.amount" class="text item">
                <el-row>
                    <div style="float: left">
                        <el-button-group style="margin-right: 5px;">
                            <el-button v-bind:id="'removeIncome'+income.amount" :disabled="!editable"
                                       :plain="true" size="mini" type="text" icon="el-icon-remove-outline"
                                       @click="removeIncome(income.id)"></el-button>
                        </el-button-group>
                        <label>{{ income.description }}</label>
                    </div>
                    <label style="float: right;">{{ formatPrice(income.amount) }}</label>
                </el-row>
            </div>
        </el-row>

        <el-dialog title="Facturas abiertas en alegra" :visible.sync="visible" width="80%"
                   center>
            <div v-if="!loaded">
                <h3> Consultando facturas en alegra ... </h3>
            </div>
            <div v-else>
                <el-row>
                    <el-table id='tableInvoice' :data="invoices" height="250" size="small">
                        <el-table-column property="id" label="Número" width="80"></el-table-column>
                        <el-table-column property="date" label="Fecha Expedición" width="130"></el-table-column>
                        <el-table-column property="client.name" label="Cliente" width="450"></el-table-column>
                        <el-table-column property="total" label="Monto" width="120">
                            <template slot-scope="scope">
                                 <span style="float: right;" :id="scope.row.id">
                                                      {{ formatPrice(scope.row.total) }}
                                </span>
                            </template>
                        </el-table-column>
                        <el-table-column label="opciones">
                            <template slot-scope="scope">
                                <el-button id="agregar" :disabled="!editable" type="text"
                                           @click='addToBalance(scope.row)' icon="el-icon-success">Agregar</el-button>
                            </template>
                        </el-table-column>
                    </el-table>
                </el-row>
            </div>


            <span slot="footer" class="dialog-footer">
                <el-button @click="closeDialog()">Cerrar</el-button>
            </span>
        </el-dialog>
    </el-card>
</template>
<script>

  import invoiceConnector from '../../model/invoices_connector'
  import util from '../../model/util'
  import balanceConnector from '../../model/balance_connector'

  export default {
    name: 'invoice-selector',
    props: {
      editable: {
        type: [Boolean],
        default: true
      },
      allIncomes: {
        type: [Array],
        default: []
      }
    },
    data () {
      return {
        loaded: false,
        visible: false,
        invoices: [],
        realIncomes: [],
        income: {
          description: '',
          amount: '',
          invoiceId: '',
          date: ''
        }
      }
    },
    created: function () {
      this.realIncomes = this.allIncomes
    },
    methods: {
      openDialog () {
        this.visible = true
        invoiceConnector.findInvoices(this)

      },
      closeDialog () {
        this.visible = false
        this.loaded = false
      },
      addToBalance(invoice) {
        this.income.description = "Factura " + invoice.id
        this.income.amount = invoice.total
        this.income.invoiceId = invoice.id
        this.income.date = invoice.date
        balanceConnector.addIncome(this, this.$route.params.id, function (context) {
          context.loaded = false
          context.visible = false
        })
      },
      removeIncome (incomeId) {
        balanceConnector.removeIncome(this, this.$route.params.id, incomeId)
      },
      formatPrice (value) {
        return util.formatPrice(value)
      }

    }
  }

</script>


<style scoped>
    .center {
        text-align: center;
    }

</style>
