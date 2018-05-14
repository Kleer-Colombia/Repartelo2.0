<template>
    <el-main>
        <el-button  type="primary" @click="dialogFormVisible = true">Agregar registro</el-button>
        
        <el-dialog :title="'Agregando registro para ' + kleerer.name" :visible.sync="dialogFormVisible">
          <el-form label-width="120px">
          <el-form-item label="Monto">
              <input-money name="amount" v-model="saldo.amount"></input-money>       
              Si deseas agregar un egreso, por favor pon la cifra NEGATIVA
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
    data () {
      return {
        dialogFormVisible: false,
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
      addSaldo () {
        saldosConnector.addSaldo(this, {saldo: this.saldo})
      },
      closeDialog (format) {
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
