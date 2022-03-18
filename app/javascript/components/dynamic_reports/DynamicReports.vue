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
                  <h2 id="objetivo">{{ this.formatPrice(this.yearObjective.amount) }}</h2>
                  <div class="objective-buttons">
                    <div v-if="this.years.filteredYear === this.years.currentYear">
                      <add-objective-button/>
                    </div>
                    <div v-if="!yearObjective.amount.includes('No')">
                      <all-objectives-button v-bind:objectives="objectives" v-bind:year="years.filteredYear"/>
                    </div>
                  </div>
                  
                </div>
              </el-card>
            </el-col>
            <el-col v-if="this.getPositiveBalance()" :span="10" :offset="1">
              <el-card class="positive box-card">
                <div slot="header" class="clearfix">
                  <h2>Saldo a favor</h2>
                </div>
                <h2 id="saldo-favor">{{ this.formatPrice(this.getPositiveBalance()) }}</h2>
              </el-card>
            </el-col>
            <el-col v-if="this.getOutstandingBalance()" :span="10" :offset="1">
              <el-card class="negative box-card">
                <div slot="header" class="clearfix">
                  <h2>Saldo pendiente</h2>
                </div>
                <h2 id="saldo-pendiente">{{ this.formatPrice(this.getOutstandingBalance()) }}</h2>
              </el-card>
            </el-col>
            <el-col :span="10" :offset="1">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Saldo inicial</h2>
                </div>
                <h2 id="saldo-inicial">{{ this.formatPrice(initialBalance) }}</h2>
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
            :data="filteredKleerers2"
            border
            style="width: 100%"
          >
            <el-table-column prop="name" label="Kleerer"> </el-table-column>
            <el-table-column label="Aporte a Kleer Colombia" prop="income">
            </el-table-column>
            <el-table-column label="Meta anual" prop="anualMeta">
            </el-table-column>
            <el-table-column label="Saldo inicial" prop="formatInitialIncome">
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
import AllObjectivesButton from './AllObjectivesButton.vue';
import dealer from "../../model/objectives_distributions";

export default {
  name: "DynamicReports",
  components: { SafeBody, AddObjectiveButton, AllObjectivesButton },
  data() {
    return {
      loaded: false,
      kleerCo: {},
      kleerers: [],
      objectives: [],
      kleerCoIncome: 0,
      initialBalance: 0,
      yearObjective: {},
      objectiveByKleerer: 0,
      lastObjectiveByKleerer: 0,
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

      filteredKleerers2:[
        {
          kleerer: "",
          inputFormat: 0,
        },
      ],
      kleerersByYears: [],
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
      this.filterObjectives();
      this.filterKleerers();
      this.filterKleerCoIncome();
      this.getInitialBalance()
    },

    filterKleerCoIncome(){
      
      this.kleerCoIncome = this.kleerCo.meses.reduce((total, month) => {
        if (month.fecha.includes(this.years.filteredYear.toString())) {
          return total + Number(month.ingresos);
        }
        return total + 0;
      },0);
    },

    filterKleerers() {
      this.objectiveByKleerer = this.yearObjective.amount / dealer.findKleerersWithMeta(this.kleerers).length
      this.lastObjectiveByKleerer = this.lastObjective.amount / dealer.findKleerersWithMeta(this.kleerers).length

      this.filteredKleerers2 = this.kleerersByYears
        .find((kleerer) => kleerer.year === this.years.filteredYear).kleerers
        .filter((kleerer) => kleerer.hasMeta)
        .map(kleerer => {
          return {
            name: kleerer.name,
            anualMeta: this.formatPrice(kleerer.anualMeta),
            hasMeta: kleerer.hasMeta,
            income: this.formatPrice(kleerer.income),
            initialIncome: kleerer.initial_income,
            formatInitialIncome: this.formatPrice(kleerer.initial_income),
            positiveBalance: kleerer.balance > 0 ? this.formatPrice(kleerer.balance) : this.formatPrice(0),
            outstandingBalance: kleerer.balance < 0 ? this.formatPrice(kleerer.balance * -1) : this.formatPrice(0),
          }
        })

      
    },

    filterObjectives(){
      this.yearObjective = dealer.filterObjectives(
        this.objectives,
        this.years.filteredYear
      );

      this.lastObjective = dealer.filterObjectives(
        this.objectives,
        this.years.filteredYear - 1
      )
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
      const initialBalance = typeof(this.initialBalance) === 'number' ? this.initialBalance : 0;
      
      const balance = this.kleerCoIncome + initialBalance - this.yearObjective.amount;
      return balance > 0 ? balance : false;
    },

    getOutstandingBalance(){
      const initialBalance = typeof(this.initialBalance) === 'number' ? this.initialBalance : 0;

      const balance = this.yearObjective.amount - this.kleerCoIncome - initialBalance;
      return balance > 0 ? balance : false;
    },

    getInitialBalance(){
      if(!this.yearObjective.initial_balance_percentage){
        this.initialBalance = 'No hay porcentage inicial'
      }else{
        //hay que meter variable al back los datos generales
        const initialBalance = this.filteredKleerers2.reduce((total, kleerer) => {

                            return total + parseFloat(kleerer.initialIncome);
      }, 0);
      
      this.initialBalance = initialBalance
      }
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
.positive{
  box-shadow: 0 2px 12px 0 green !important
}

.negative{
  box-shadow: 0 2px 12px 0 red !important
}
</style>


