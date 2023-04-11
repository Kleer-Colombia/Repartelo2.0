<template>
  <el-main>
    <el-button type="primary" @click="dialogFormVisible = true">Agregar clearing</el-button>

    <el-dialog :title="'Agregando clearing'" :visible.sync="dialogFormVisible">
      <el-form label-width="120px">
        <el-form-item label="Monto">
          <input-money name="amount" :format="format" v-model="clearing.amount"></input-money>
          <el-radio v-model="format" label="income">Ingreso</el-radio>
          <el-radio v-model="format" label="expense">Egreso</el-radio>
        </el-form-item>
        <el-form-item label="Descripción">
          <el-input placeholder="description"
                    name="description"
                    v-model="clearing.description"></el-input>
        </el-form-item>
        <el-form-item label="Kleerer">
          <el-input name="extKleerer"
                    placeholder="kleerer"
                    v-model="clearing.extKleerer"></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cancelar</el-button>
            <el-button type="primary" @click="addClearing()">Guardar</el-button>
        </span>
    </el-dialog>
  </el-main>
</template>


<script>

  import InputMoney from '../base/InputMoney.vue'
  import clearingConnector from '../../model/clearing_connector'

  export default {
    components: {
      InputMoney
    },
    data() {
      return {
        dialogFormVisible: false,
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
        clearing: {
          amount: '',
          description: '',
          extKleerer: '',
        }
      }
    },
    methods: {
      addClearing() {
        this.convertAmount()
        clearingConnector.addClearing(this, {clearing: this.clearing})
      },
      convertAmount() {
        this.clearing.amount = Math.abs(this.clearing.amount)
        if(this.format === "expense"){
          this.clearing.amount = this.clearing.amount * -1
        }
      },
      closeDialog(format) {
        if (format) {
          this.clearing = {
            amount: '',
            description: '',
            extKleerer: '',
          }
        }
        this.dialogFormVisible = false
      },
      validateDate(date){
        console.log(date)
        return false
      }
    },
    
  }
</script>
