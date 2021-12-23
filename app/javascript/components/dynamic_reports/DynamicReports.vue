<template>
  <SafeBody tittle="Aporte por ventas a Kleer Colombia">
    <div v-if="!loaded">
      <h1> Cargando ... </h1>
    </div>
    <div v-else>

      <el-row :gutter="20">
        <el-col :span="18" :offset="6">
          <el-row :gutter="20">
            <el-col :span="9" style="padding-top: 10px;">
              <el-radio-group v-model="years.filteredYear" @change="filter()">
                <el-radio v-for="year in years.disponibleYears" :label="year">
                  {{ year }}
                </el-radio>
              </el-radio-group>
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="12" :offset="2">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Ingresos anuales</h2>
                </div>
                <h2 id="ingresos-kleerco">{{ this.filter() }}</h2>
              </el-card>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
    </div>

  </SafeBody>
</template>

<script>
import SafeBody from '../base/SafeBody'
import DynamicReportConnector from '../../model/dynamic_report_connector'
import util from '../../model/util'

export default {
  name: 'DynamicReports',
  components: {SafeBody},
  data(){
    return{
      loaded: false,
      kleerCo: {},
      kleerers: [],
      years: {
        disponibleYears: [],
        filteredYear: 2021
      },
    }
  },
  created () {
    DynamicReportConnector.getData(this, context => {
      context.loaded = true 
      this.getDisponibleYears()
    })
    
    
  },
  methods: {
    filter(){

      const totalIncome = this.kleerCo.meses.reduce((total, month) => {
        if (month.fecha.includes(this.years.filteredYear.toString())) {
          return total + parseFloat(month.ingresos);
        }
        return total + 0
      }, 0)

      return util.formatPrice(totalIncome)
    },

    getDisponibleYears(){
      let actualYear = new Date().getFullYear()
      this.kleerCo.meses.forEach(date => {
        if(date.fecha.includes(actualYear)){
          this.years.disponibleYears.push(actualYear--)
        }
      });
    }
  }
}
</script>

<style scoped>

</style>
