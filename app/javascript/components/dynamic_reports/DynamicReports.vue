<template>
  <SafeBody tittle="Aporte por ventas a Kleer Colombia">
    <div v-loading="!loaded">
      <el-row :gutter="20">
        <el-col :span="20" :offset="2">
          <el-row :gutter="20">
            <el-col :span="9" style="padding-top: 10px">
              <el-radio-group v-model="years.filteredYear" @change="filter()">
                <el-radio v-for="year in years.disponibleYears" :label="year">
                  {{ year }}
                </el-radio>
              </el-radio-group>
            </el-col>
          </el-row>
          <el-row>
            <el-col :span="10" :offset="1">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Ingresos anuales</h2>
                </div>
                <h2 id="ingresos-kleerco">{{ this.formatPrice(this.kleerCoIncome) }}</h2>
              </el-card>
            </el-col>
            <el-col :span="10" :offset="1">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Objetivo anual</h2>
                </div>
                <div class="objective-container">
                  <h2 id="objetivo">{{ this.formatPrice(this.yearObjective) }}</h2>
                  <div v-if="this.years.filteredYear === this.years.currentYear">
                    <add-objective-button />
                  </div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="10" :offset="1">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Saldo a favor</h2>
                </div>
                <h2 id="saldo-favor">{{ this.formatPrice(this.getPositiveBalance()) }}</h2>
              </el-card>
            </el-col>
            <el-col :span="10" :offset="1">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Saldo pendiente</h2>
                </div>
                <h2 id="saldo-pendiente">{{ this.formatPrice(this.getOutstandingBalance()) }}</h2>
              </el-card>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
      <br />
      
      <el-row :gutter="20">
        <el-col :span="20" :offset="2" style="padding-top: 10px">
          <h2>Aportes por kleerer</h2>
          <el-table
            :id="kleerers"
            :data="filteredKleerers"
            border
            :default-sort="{ prop: 'kleerer', order: 'ascending' }"
            style="width: 100%"
          >
            <el-table-column prop="name" label="Kleerer"> </el-table-column>
            <el-table-column label="Aporte a Kleer Colombia" prop="inputFormat">
            </el-table-column>
            <el-table-column label="Meta anual" prop="anualMeta">
            </el-table-column>
            <el-table-column label="Saldo pendiente" prop="outstandingBalance">
            </el-table-column>
            <el-table-column label="Saldo a favor" prop="positiveBalance">
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </div>
  </SafeBody>
</template>

<script>
import SafeBody from "../base/SafeBody";
import DynamicReportConnector from "../../model/dynamic_report_connector";
import util from "../../model/util";
import AddObjectiveButton from './AddObjectiveButton.vue';

export default {
  name: "DynamicReports",
  components: { SafeBody, AddObjectiveButton },
  data() {
    return {
      loaded: false,
      kleerCo: {},
      kleerers: [],
      objectives: [],
      kleerCoIncome: 0,
      yearObjective: 0,
      objectiveByKleerer: 0,
      filteredKleerers: [
        {
          kleerer: "",
          inputFormat: 0,
        },
      ],
      years: {
        disponibleYears: [],
        filteredYear: new Date().getFullYear(),
        currentYear: new Date().getFullYear(),
      },
    };
  },
  created() {
    DynamicReportConnector.getData(this, (context) => {
      context.loaded = true;
      
      this.getDisponibleYears();
      this.filter();
    });
  },
  methods: {
    filter() {
      this.filterKleerCoIncome();
      this.filterObjectives();
      this.filterKleerers();
    },

    filterKleerCoIncome(){
      this.kleerCoIncome = this.kleerCo.meses.reduce((total, month) => {
        if (month.fecha.includes(this.years.filteredYear.toString())) {
          return total + parseFloat(month.ingresos);
        }
        return total + 0;
      }, 0);
    },

    filterKleerers() {
      const kleerersWithMeta = this.kleerers.filter(kleerer => {
        return kleerer.hasMeta;
      }).length;

      this.objectiveByKleerer = this.yearObjective / kleerersWithMeta;

      this.filteredKleerers = this.kleerers
        .map((kleerer) => {
          
          let totalIncome = 0;
          if (kleerer.inputs.length !== 0) {
            try {
              totalIncome = kleerer.inputs.find((input) => {
                return input.year === this.years.filteredYear;
              }).input;
            } catch (e) {
              totalIncome = 0;
            }
          }
          const anualMeta = kleerer.hasMeta ? this.formatPrice(this.objectiveByKleerer) : 'No tiene meta';

          const positiveBalance = kleerer.hasMeta ? (totalIncome - this.objectiveByKleerer > 0 ? 
                              this.formatPrice(totalIncome - this.objectiveByKleerer) : this.formatPrice(0))
                              : 'No tiene meta';

          const outstandingBalance = kleerer.hasMeta ? (this.objectiveByKleerer - totalIncome > 0 ? 
                              this.formatPrice(this.objectiveByKleerer - totalIncome) : this.formatPrice(0))
                              : 'No tiene meta';

          return {
            name: kleerer.name,
            inputFormat: this.formatPrice(totalIncome),
            input: totalIncome,
            hasMeta: kleerer.hasMeta,
            anualMeta: anualMeta ? anualMeta : 'No meta disponible',
            positiveBalance: positiveBalance,
            outstandingBalance: outstandingBalance                 
          };
        })
      .filter((kleerer) => {
        return kleerer.input !== 0 || kleerer.hasMeta;
      })
      .sort((a,b) => {
        return b.input - a.input;
      });
      console.log(this.filteredKleerers);
    },

    filterObjectives(){
      let objective 

      try{
        objective = this.objectives.find((objective) => {
          return objective.year === this.years.filteredYear;
        }).actual.amount;

        this.yearObjective = objective;
      }catch(e){
        this.yearObjective = 'No hay metas disponibles para este año'
      }
      
    },
    
    getDisponibleYears() {
      let actualYear = new Date().getFullYear();
      this.kleerCo.meses.forEach((date) => {
        if (date.fecha.includes(actualYear) || date.fecha.includes(actualYear - 1)) {
          this.years.disponibleYears.push(actualYear--);
        }
      });
    },

    getPositiveBalance(){
      const balance = this.kleerCoIncome - this.yearObjective;
      return balance > 0 ? balance : 0;
    },

    getOutstandingBalance(){
      const balance = this.yearObjective - this.kleerCoIncome;
      return balance > 0 ? balance : 0;
    },

    formatPrice(price) {
      const formattedPrice = util.formatPrice(price);
      if(formattedPrice !== '$NaN'){
        return formattedPrice;
      }else{
        return price;
      }
    },
  },
};
</script>

<style scoped>
.objective-container {
  display: flex;
  justify-content: space-between;
  width: 100%;
}
</style>
