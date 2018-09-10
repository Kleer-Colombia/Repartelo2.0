<template>
  <safe-body tittle='Nuevo balance'>
    <el-row :gutter="20">
    <el-col :span="10" :offset="7">
       
      <el-card class="box-card">
        <el-form  label-width="100px">
            <el-form-item label="Cliente">
                <el-input name="client" 
                        placeholder="Cliente"
                        v-model="balance.client"></el-input>
            </el-form-item>
            <el-form-item label="Proyecto">
                <el-input name="project"  
                        placeholder="Proyecto"
                        v-model="balance.project"></el-input>
            </el-form-item>
            <el-form-item label="Fecha">
                <el-date-picker
                      v-model="balance.date"
                      type="date"
                      v-bind:id="'date'"
                      placeholder="Fecha">
                </el-date-picker>
            </el-form-item>
            <el-form-item label="Descripción">
                <el-input type="textarea"
                        :rows="3"   
                        placeholder="Descripción"
                        name="description"  
                        v-model="balance.description"></el-input>
            </el-form-item>
            <el-form-item label="Tipo">
                <el-radio id="standard" v-model="balance.balance_type" label="standard">Estándar</el-radio>
                <el-radio id="coaching" v-model="balance.balance_type" label="coaching">Coaching</el-radio>
            </el-form-item>
            <el-form-item>
            <el-button type="primary" @click="guardar()">Guardar</el-button>
            </el-form-item>
        </el-form>
      </el-card>

    </el-col>
  </el-row>
  </safe-body>
</template>
<script>

import balanceConnector from '../../model/balance_connector'
import SafeBody from '../base/SafeBody.vue'

export default {
  name: 'newBalance',
  components: {
    SafeBody
  },
  data () {
    return {
      balance: {
        client: '',
        project: '',
        description: '',
        date: '',
        balance_type: ''
      }
    }
  },
  methods: {
    guardar () {
      balanceConnector.createBalance(this, {balance: this.balance})
    }
  }
}
</script>
