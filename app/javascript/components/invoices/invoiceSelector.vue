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
				<el-row id="tableInvoice">
					<el-table highlight-current-row @current-change="handleSelectInvoice"
					          :data="invoices" height="300" size="small">
						<el-table-column property="id" label="Número" width="100" class="id">
							<template slot-scope="scope">
                 <span style="float: right;">
                    {{ scope.row.numberTemplate.number }} ({{scope.row.id}})
                </span>
							</template>
						</el-table-column>
						<el-table-column property="date" label="Fecha Expedición" width="130"></el-table-column>
						<el-table-column property="client.name" label="Cliente" width="550"></el-table-column>
						<el-table-column property="total" label="Monto" width="120">
							<template slot-scope="scope">
                                 <span style="float: right;">
                                                      {{ formatPrice(scope.row.total) }}
                                </span>
							</template>
						</el-table-column>
						<el-table-column property="client.name" label="Moneda" width="120">
							<template slot-scope="scope">
                                 <span style="float: center;" v-if="scope.row.currency">
                                  {{scope.row.currency.code}}
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
				<el-col :span="2" style="padding-top: 10px; text-align: center">
					 {{percentageSelector.min}}%
				</el-col>
				<el-col :span="8">
				
				<el-slider
								v-model="percentageSelector.digit"
								:max="percentageSelector.max"
								:min="percentageSelector.min"
								@change="calculatePercentageTotal()"
								:disabled="!percentageSelector.canAddDigits"
								>
				</el-slider>
				
				</el-col>
				<el-col :span="2" style="padding-top: 10px; text-align: center">
					   {{percentageSelector.max}}%
				</el-col>
				
				<el-col :span="2" style="padding-top: 10px; text-align: center">
					Decimales .{{percentageSelector.minDecimal}}
				</el-col>
				<el-col :span="8">
					
					<el-slider
									v-model="percentageSelector.decimals"
									:max="percentageSelector.maxDecimal"
									:min="percentageSelector.minDecimal"
									@change="calculatePercentageTotal()"
									:disabled="!percentageSelector.canAddDecimals"
									
					>
					</el-slider>
				
				</el-col>
				<el-col :span="2" style="padding-top: 10px; text-align: center">
					. {{percentageSelector.maxDecimal}}
				</el-col>
			</el-row>
			
			<el-row>
				<el-col :offset="3" :span="10" style="padding-top: 10px; text-align: center">
					TRM: (solo se aplica a monedas diferentes a COP, por favor usa la pactada en el banco)
				</el-col>
				<el-col :span="4">
					<input-money name="trm" v-model="trm"></input-money>
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
  import InputMoney from "../base/InputMoney";

  export default {
    name: 'invoice-selector',
    components: {InputMoney},
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
	      trm: '1.0',
	      selectedInvoice: null,
	      canAddInvoice: false,
        realIncomes: [],
        income: {
          description: '',
          amount: '',
          invoiceId: '',
          date: '',
	        trm: ''
        },
	      percentageSelector: {
          max: 100,
		      min: 0,
		      digit: 0,
		      decimals: 0,
		      maxDecimal: 99,
		      minDecimal: 0,
		      percentageTotal: 0,
		      canAddDigits: false,
          canAddDecimals: false
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
	    cleanSelection () {
        this.canAddInvoice = false
        this.selectedInvoice = false
        this.percentageSelector.digit = 0
        this.percentageSelector.decimals = 0
        this.percentageSelector.percentageTotal = 0
        this.percentageSelector.max = 99
        this.percentageSelector.maxDecimal = 100
        this.percentageSelector.canAddDecimals = false
        this.percentageSelector.canAddDigits = false
	    },
      handleSelectInvoice (row) {
        this.selectedInvoice = row
	      this.canAddInvoice = true
	      let info = (this.selectedInvoice.percentageUsed + '').split('.')
        let digitPart = parseInt(info[0])
	      let decimalPart = 0
	      if (info.length === 2) {
	        let stringDecimal = info[1]
         
	        if(stringDecimal.length === 1) {
            stringDecimal = stringDecimal + '0'
	        }
	        decimalPart = parseInt(stringDecimal)
	      }
	      this.percentageSelector.max = 99 - digitPart
        this.percentageSelector.digit = this.percentageSelector.max
        this.percentageSelector.maxDecimal = 100 - decimalPart
        this.percentageSelector.decimals = this.percentageSelector.maxDecimal
	      
        this.percentageSelector.canAddDigits = this.percentageSelector.max > 0
        this.percentageSelector.canAddDecimals = this.percentageSelector.maxDecimal > 0
        
        this.calculatePercentageTotal()
        
      },
	    calculatePercentageTotal () {

        let decimals = this.percentageSelector.decimals / 100
        this.percentageSelector.percentageTotal = this.percentageSelector.digit + decimals
		    
        let totalForSelect = this.percentageSelector.max + (this.percentageSelector.maxDecimal / 100)
		    if (this.percentageSelector.percentageTotal > totalForSelect) {
		      this.percentageSelector.decimals = 0
          this.percentageSelector.percentageTotal = this.percentageSelector.max
		    }
	    },
      addToBalance () {
        this.income.description = 'Factura ' + this.selectedInvoice.numberTemplate.number + '  (' + this.selectedInvoice.id + ' - ' + this.percentageSelector.percentageTotal +'%) '
	      let trm = 1
	      console.log('currency: ' + this.selectedInvoice.currency)
	      if (this.selectedInvoice.currency) {
          trm = this.trm
		      this.income.description += '[ TRM: ' + this.formatPrice(trm) + ' ]'
	      }
	      
        this.income.amount = this.selectedInvoice.total * trm
	      this.income.trm = trm
        this.income.invoiceId = this.selectedInvoice.id
        this.income.date = this.selectedInvoice.date
	      this.income.invoicePercentageToUse = this.percentageSelector.percentageTotal
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
