<template>
    <div class="">
        <el-menu background-color="#428bca" text-color="#fff"
                 active-text-color="#f9f9f9" mode="horizontal">
            <div v-if="!isAuth()">
                <el-menu-item index="login" id="Login" @click="route_to('/')">Login</el-menu-item>
            </div>
            <div v-if="isAuth()">
                <el-menu-item index="balance" id="Balances" style="float: left;" @click="route_to('/balance')">
                    Balances
                </el-menu-item>
                <el-menu-item index="saldo" id="Saldos" style="float: left;" @click="route_to('/saldos')">Saldos
                </el-menu-item>
                <el-menu-item index="impuesto" id="Impuestos" style="float: left;" @click="route_to('/impuestos')">Impuestos
                </el-menu-item>
                <el-menu-item index="reporte" id="Reportes" style="float: left;" @click="route_to('/reportes')">Reportes
                </el-menu-item>
                <el-menu-item index="reporte" id="Reportes dinamicos" style="float: left;" @click="route_to('/reportes-dinamicos')">Reportes dinamicos
                </el-menu-item>
                <el-menu-item style="float: right;" id="Logout" @click="logout()" index="logout">Logout</el-menu-item>
            </div>
        </el-menu>

        <div id="app">
            <router-view></router-view> <!-- inyecta los componentes de acuerdo al router-->
        </div>
    </div>
</template>

<script>

  import auth from './model/auth'
  import util from './model/util'
  import router from './router'

  export default {
    name: 'app',
    methods: {
      logout () {
        auth.logout()
      },
      route_to (uri) {
        router.push(uri)
      },
      isAuth () {
        return util.checkAuth()
      }
    }
  }
</script>
