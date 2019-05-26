<template>
  <SafeBody tittle="Saldos Kleerers">
      <el-row>
        <el-col :span="20" :offset="2">
            <el-card class="box-card">
              <el-tabs v-model="activeTab" style="margin-bottom: 30px;">
                <el-tab-pane v-for="kleerer in kleerers" :key="kleerer.name" v-bind:label="kleerer.name" v-bind:name="kleerer.name">
                  <saldos-detail v-bind:kleerer="kleerer"/>
                </el-tab-pane>
              </el-tabs>
            </el-card>
        </el-col>
      </el-row>
  </SafeBody>
</template>

<script>

  import SafeBody from '../base/SafeBody.vue'
  import SaldosDetail from './SaldosDetail.vue'
  import kleerersConnector from '../../model/kleerers_connector'

  export default {
    components: {
      SafeBody,
      SaldosDetail
    },
    data () {
      return {
        kleerers: [],
        activeTab: 'KleerCo'
      }
    },
    created: function () {
      kleerersConnector.getKleerers(this)
    }
  }
  </script>
