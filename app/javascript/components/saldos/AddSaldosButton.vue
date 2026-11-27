<template>
  <el-main>
    <el-button type="primary" @click="dialogFormVisible = true">Agregar registro</el-button>

    <el-dialog :title="'Agregando registro para ' + kleerer.name" :visible.sync="dialogFormVisible">
      <el-form ref="saldoForm" :model="saldo" :rules="rules" label-width="120px">
        <el-form-item label="Monto" prop="amount">
          <input-money name="amount" :format="format" v-model="saldo.amount"></input-money>
          <el-radio v-model="format" label="income">Ingreso</el-radio>
          <el-radio v-model="format" label="expense">Egreso</el-radio>
        </el-form-item>
        <el-form-item label="Concepto" prop="concept">
          <el-input placeholder="Concepto"
                    name="concept"
                    v-model="saldo.concept"></el-input>
        </el-form-item>
        <el-form-item label="Referencia" prop="reference">
          <el-input name="reference"
                    placeholder="Referencia"
                    v-model="saldo.reference"></el-input>
          Link al soporte de este registro o una ruta del dropbox de K.Co
        </el-form-item>

        <el-form-item label="Fecha">
          <el-date-picker
                  v-model="saldo.date"
                  type="date"
                  v-bind:id="'saldo_date'"
                  placeholder="Fecha"
                  :picker-options="startDatePicker">
                  
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
        // Mismas reglas que el servidor (app/models/saldo.rb): monto distinto
        // de 0, concepto y referencia obligatorios. La fecha es opcional (hoy).
        rules: {
          amount: [{
            validator: (rule, value, callback) => {
              Number(value) ? callback() : callback(new Error('Ingresá un monto distinto de 0'))
            },
            trigger: 'blur'
          }],
          concept: [{ required: true, whitespace: true, message: 'El concepto es obligatorio', trigger: 'blur' }],
          reference: [{ required: true, whitespace: true, message: 'La referencia es obligatoria', trigger: 'blur' }]
        },
        format: "income",
        startDatePicker: {
          disabledDate(time) {
            const today = new Date()
            const todayDay = today.getDate()
            if(todayDay >= 10){
              return time.getTime() < new Date(today.getFullYear(), today.getMonth(), 1).getTime()
            }else{
              return time.getTime() < new Date(today.getFullYear(), today.getMonth() - 1, 1).getTime()
            }
          }
        },
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
        this.$refs.saldoForm.validate((valid) => {
          if (!valid) return
          this.convertAmount()
          saldosConnector.addSaldo(this, {saldo: this.saldo})
        })
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
        if (this.$refs.saldoForm) this.$refs.saldoForm.clearValidate()
        this.dialogFormVisible = false
      },
      validateDate(date){
        console.log(date)
        return false
      }
    },
    
  }
</script>
