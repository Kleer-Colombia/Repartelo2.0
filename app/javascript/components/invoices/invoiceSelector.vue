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

		<el-dialog title="Facturas abiertas en alegra" :visible.sync="visible" width="90%"
		           center>
			<div v-if="!loaded">
				<h3> Consultando facturas en alegra ... </h3>
			</div>
			<div v-else>
				<el-row>
					<el-table id='tableInvoice' highlight-current-row @current-change="handleSelectInvoice"
					          :data="invoices" height="300" size="small">
						<el-table-column property="id" label="Número" width="100"></el-table-column>
						<el-table-column property="date" label="Fecha Expedición" width="130"></el-table-column>
						<el-table-column property="client.name" label="Cliente" width="550"></el-table-column>
						<el-table-column property="total" label="Monto" width="120">
							<template slot-scope="scope">
                                 <span style="float: right;">
                                                      {{ formatPrice(scope.row.total) }}
                                </span>
							</template>
						</el-table-column>
						<el-table-column property="percentageUsed" label="Usada al">
							<template slot-scope="scope">
               <span>
                {{ scope.row.percentageUsed }} %
                </span>
							</template>
						</el-table-column>
					</el-table>
				</el-row>
			</div>
			
			<el-row>
				<el-col :span="4" style="padding-top: 10px; text-align: right">
					 {{percentageSelector.min}}%
				</el-col>
				<el-col :span="16">
				
				<el-slider
								v-model="percentageSelector.percentageToUse"
								:max="percentageSelector.max"
								:min="percentageSelector.min"
								>
				</el-slider>
				
				</el-col>
				<el-col :span="4" style="padding-top: 10px">
					   {{percentageSelector.max}}%
				</el-col>
			</el-row>
			
			<el-row>
				<el-col :span="24" style="text-align: center">
					<h5>Porcentaje a utilizar: {{ percentageSelector.percentageToUse}}%</h5>
				</el-col>
			</el-row>
			
			<span slot="footer" class="dialog-footer">
				<el-button  type="primary" :disabled="!canAddInvoice || !editable"
				           @click='addToBalance()' icon="el-icon-success">Agregar</el-button>
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
	      selectedInvoice: null,
	      canAddInvoice: false,
        realIncomes: [],
        income: {
          description: '',
          amount: '',
          invoiceId: '',
          date: ''
        },
	      percentageSelector: {
          max: 100,
		      min: 0,
		      percentageToUse: 0
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
	      this.cleanSelection()
      },
	    cleanSelection(){
        this.canAddInvoice = false
        this.selectedInvoice = false
        this.percentageSelector.percentageToUse = 0
        this.percentageSelector.max = 100
	    },
      handleSelectInvoice (row) {
        this.selectedInvoice = row
	      this.canAddInvoice = true
        this.percentageSelector.max = 100 - this.selectedInvoice.percentageUsed
        this.percentageSelector.percentageToUse = this.percentageSelector.max
        
      },
      addToBalance () {
        
        this.income.description = 'Factura ' + this.selectedInvoice.id + '  ('+ this.percentageSelector.percentageToUse +'%)'
        this.income.amount = this.selectedInvoice.total
        this.income.invoiceId = this.selectedInvoice.id
        this.income.date = this.selectedInvoice.date
	      this.income.invoicePercentageToUse = this.percentageSelector.percentageToUse
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
