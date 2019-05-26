<template>
    <SafeBody tittle="Impuestos">
        <el-row>
            <el-col :span="20" :offset="2">
                <el-card class="box-card">
                    <el-tabs v-model="activeTab" style="margin-bottom: 30px;">
                        <el-tab-pane v-for="tax in taxes" :key="tax.name"
                                     v-bind:label="tax.name" v-bind:name="tax.name">
                            <taxes-detail v-bind:taxDetail="tax.detail"/>
                        </el-tab-pane>
                    </el-tabs>
                </el-card>
            </el-col>
        </el-row>
    </SafeBody>
</template>

<script>
  import SafeBody from '../base/SafeBody.vue'
  import TaxesDetail from './TaxesDetail.vue'
  import taxesConnector from '../../model/taxes_connector'

  export default {
    name: 'Taxes',
    components: {
      SafeBody,
      TaxesDetail
    },
    data () {
      return {
        taxes: [],
        activeTab: 'Ica'
      }
    },
    created: function () {
      taxesConnector.find(this)
    }
  }
</script>

<style scoped>

</style>
