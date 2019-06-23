<template>
	
	<el-row>
		<el-col :span="20" :offset="2">
			<el-tabs v-model="activeTab" style="margin-bottom: 30px;">
				<el-tab-pane v-for="year in tax.years" :key="year.year"
				             v-bind:label="year.year" v-bind:name="year.year">
					<taxes-detail v-bind:tax="tax" v-bind:taxDetails="year.taxDetails" v-bind:taxYear="year.year"/>
				</el-tab-pane>
			</el-tabs>
		</el-col>
	</el-row>

</template>

<script>
  import TaxesDetail from './TaxesDetail.vue'

  export default {
    name: 'Taxes',
    components: {
      TaxesDetail
    },
    props: {
      tax: {
        type: Object,
        default: ''
      }
    },
    data () {
      return {
        taxes: [],
        activeTab: ''
      }
    },
    mounted () {
      this.getCurrentYear()
    },
    methods: {
      getCurrentYear () {
	      this.activeTab = new Date().getFullYear()+''
      }
    }
  }
</script>

<style scoped>

</style>
