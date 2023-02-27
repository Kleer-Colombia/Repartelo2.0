<template>
<el-row :gutter="20">
  <el-row :gutter="20">
    <el-col :span="8" :offset="8">
      <div class="grid-content"></div>
      <el-form label-position="top" label-width="100px">
      
        <el-card class="box-card">
          <h3>Ingresa a Repartelo</h3> 
          <el-form-item label="Ingresa tu Email">
            <el-input name="email" v-model="credentials.username"></el-input>
          </el-form-item>
          <el-form-item label="Ingresa tu password">
            <el-input name="password" type="password" v-model="credentials.password"></el-input>
          </el-form-item>
          <el-form-item>
          <el-button type="primary" @click="submit()">Entrar</el-button>
        </el-form-item>
      </el-card>
  </el-form>
    </el-col>
  </el-row>
 </el-row>
</template>

<style>
  .el-row {
    margin-bottom: 20px;
    &:last-child {
      margin-bottom: 0;
    }
  }
  
  .grid-content {
    border-radius: 4px;
    min-height: 36px;
  }
 
</style>

  <script>

  import auth from '../model/auth'
  import util from '../model/util'
  import router from '../router'
  
  export default {
    data () {
      return {
        // We need to initialize the component with any
        // properties that will be used in it
        credentials: {
          username: '',
          password: ''
        }
      }
    },
    created () {
      if(this.isAuth()){
        router.push('/balance')
      }
    },
    methods: {
      submit () {
        var credentials = {
          username: this.credentials.username,
          password: this.credentials.password
        }
        auth.login(this, credentials, '/balance')
      },
      isAuth () {
        return util.checkAuth()
      }
    }
  }
  </script>
