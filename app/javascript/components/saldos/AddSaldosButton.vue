<template>
  <el-main>
    <el-button type="primary" @click="dialogFormVisible = true">Agregar registro</el-button>

    <el-dialog :title="'Agregando registro para ' + kleerer.name" :visible.sync="dialogFormVisible">
      <el-form label-width="120px">
        <el-form-item label="Monto">
          <input-money name="amount" :format="format" v-model="saldo.amount"></input-money>
          <el-radio v-model="format" label="income">Ingreso</el-radio>
          <el-radio v-model="format" label="expense">Egreso</el-radio>
        </el-form-item>
        <el-form-item label="Concepto">
          <el-input placeholder="Concepto"
                    name="concept"
                    v-model="saldo.concept"></el-input>
        </el-form-item>
        <el-form-item label="Referencia">
          <el-input name="reference"
                    placeholder="Referencia"
                    v-model="saldo.reference"></el-input>
          Puede ser un link al soporte de este registro, una ruta del dropbox de K.Co o estar en blanco
        </el-form-item>

        <el-form-item label="Fecha">
          <el-date-picker
                  v-model="saldo.date"
                  type="date"
                  v-bind:id="'saldo_date'"
                  placeholder="Fecha">
          </el-date-picker>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cancelar</el-button>
            <el-button type="primary" @click="addSaldo()">Guardar</el-button>
        </span>
    </el-dialog>
  </el-main>
</template>


<script>

  import InputMoney from '../base/InputMoney.vue'
  import saldosConnector from '../../model/saldos_connector'

  export default {
    props: {
      kleerer: {
        type: Object,
        default: ''
      }
    },
    components: {
      InputMoney
    },
    data() {
      return {
        dialogFormVisible: false,
        format: "income",
        saldo: {
          amount: '',
          reference: '',
          concept: '',
          date: '',
          kleerer_id: this.kleerer.id
        }
      }
    },
    methods: {
      addSaldo() {
        this.convertAmount()
        saldosConnector.addSaldo(this, {saldo: this.saldo})
      },
      convertAmount() {
        this.saldo.amount = Math.abs(this.saldo.amount)
        if(this.format === "expense"){
          this.saldo.amount = this.saldo.amount * -1
        }
      },
      closeDialog(format) {
        if (format) {
          this.saldo = {
            amount: '',
            reference: '',
            concept: '',
            date: '',
            kleerer_id: this.kleerer.id
          }
        }
        this.dialogFormVisible = false
      }
    }
  }
</script>
