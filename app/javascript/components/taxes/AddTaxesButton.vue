<template>
  <el-main>
    <el-button type="primary" @click="dialogFormVisible = true">Agregar {{tax.name}}</el-button>

    <el-dialog :title="'Agregando impuesto para ' + tax.name + ' - ' + taxYear" :visible.sync="dialogFormVisible">
      <el-form label-width="220px">
        <el-form-item label="Monto">
          <input-money name="amount" :format="format" v-model="taxInfo.amount"></input-money>
          <el-radio v-model="format" label="expense">Pagado</el-radio>
          <el-radio v-model="format" label="income">Retenido</el-radio>
        </el-form-item>
        <el-form-item label="Concepto">
          <el-input placeholder="Concepto"
                    name="concept"
                    type="textarea"
                    v-model="taxInfo.concept"></el-input>
          Agrega información relvante, periodo del impuesto, url de Dropbox, etc.
        </el-form-item>

        <el-form-item label="Fecha del IMPUESTO">
          <el-date-picker
                  v-model="taxInfo.date"
                  type="date"
                  v-bind:id="'tax_date'"
                  placeholder="Impuesto">
          </el-date-picker>
        </el-form-item>
  
        <el-form-item label="Fecha del PAGO">
          <el-date-picker
                  v-model="taxInfo.paymentDate"
                  type="date"
                  v-bind:id="'payment_date'"
                  placeholder="Pago">
          </el-date-picker>
        </el-form-item>
        
      </el-form>
      <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cancelar</el-button>
            <el-button type="primary" @click="addTax()">Guardar</el-button>
        </span>
    </el-dialog>
  </el-main>
</template>


<script>

  import InputMoney from '../base/InputMoney.vue'
  import taxesConnector from '../../model/taxes_connector'

  export default {
    props: {
      tax: {
        type: Object,
        default: ''
      },
      taxYear: {
        type: String,
        default: ''
      }
    },
    components: {
      InputMoney
    },
    data () {
      return {
        dialogFormVisible: false,
        format: 'expense',
        taxInfo: {
          amount: '',
          concept: '',
          date: '',
          paymentDate: '',
          taxName: this.tax.name,
          taxId: this.tax.id,
          taxYear: this.taxYear
        }
      }
    },
    methods: {
      addTax () {
        this.convertAmount()
        taxesConnector.addTax(this, {taxInfo: this.taxInfo})
      },
      convertAmount () {
        this.taxInfo.amount = Math.abs(this.taxInfo.amount)
        if (this.format === 'expense') {
          this.taxInfo.amount = this.taxInfo.amount * -1
        }
      },
      closeDialog (format) {
        if (format) {
          this.taxInfo = {
            amount: '',
            concept: '',
            date: '',
            tax_id: this.tax.id
          }
        }
        this.dialogFormVisible = false
      }
    }
  }
</script>
