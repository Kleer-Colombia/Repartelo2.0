<template>

<el-main>
    <el-row :gutter="20">

    <el-row :gutter="16">
        <el-col :span="8" :offset="8" style="text-align: center">
          <h2 id="titulo"> {{ tittle }} </h2> 
        </el-col>
    </el-row>

    <div v-if="!isAuth()">
     <el-row :gutter="16">
      <el-col :span="8" :offset="8" style="text-align: center">
        <el-alert title="OJO: " type="warning" :closable="false" show-icon> {{ alertMsg }} </el-alert>
      </el-col>
     </el-row>
    </div>
    <div v-else>
        <slot></slot>
    </div>
    </el-row>
  </el-main>

</template>

<script>

  import util from '../../model/util'

  export default {
    props: {
      tittle: {
        type: String,
        default: ''
      },
      alertMsg: {
        type: String,
        default: 'Necesitas estar logueado para ver esto'
      }
    },
    data () {
      return {
      }
    },
    methods: {
      isAuth () {
        return util.checkAuth()
      }
    }
  }
  </script>
