<template>
  <SafeBody tittle="Clearings por pais">
      <el-row>
        <el-col :span="20" :offset="2">
            <el-card class="box-card">
              <el-tabs v-model="activeTab" style="margin-bottom: 30px;">
                <el-tab-pane v-for="country in countries" :key="country.name" v-bind:label="country.name" v-bind:name="country.name">
                  <clearings-detail v-bind:country="country"/>
                </el-tab-pane>
              </el-tabs>
            </el-card>
        </el-col>
      </el-row>
  </SafeBody>
</template>

<script>

import SafeBody from '../base/SafeBody.vue'
import ClearingsDetail from './ClearingsDetails.vue'
import countriesConnector from '../../model/countries_connector'

export default {
    components: {
        SafeBody,
        ClearingsDetail
    },
    data () {
        return {
            countries: [],
            activeTab: 'Argentina'
        }
    },
    created: function () {
        countriesConnector.getCountries(this)
    }
}
</script>
