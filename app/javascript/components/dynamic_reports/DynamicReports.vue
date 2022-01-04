<template>
  <SafeBody tittle="Aporte por ventas a Kleer Colombia">
    <div v-if="!loaded">
      <h1>Cargando ...</h1>
    </div>
    <div v-else>
      <el-row :gutter="20">
        <el-col :span="18" :offset="6">
          <el-row :gutter="20">
            <el-col :span="9" style="padding-top: 10px">
              <el-radio-group v-model="years.filteredYear" @change="filter()">
                <el-radio v-for="year in years.disponibleYears" :label="year">
                  {{ year }}
                </el-radio>
              </el-radio-group>
            </el-col>
          </el-row>
          <el-button @click="addObjective()">objetivo</el-button>
          <el-row>
            <el-col :span="12" :offset="2">
              <el-card class="box-card">
                <div slot="header" class="clearfix">
                  <h2>Ingresos anuales</h2>
                </div>
                <h2 id="ingresos-kleerco">{{ this.ingresos_kleerco }}</h2>
              </el-card>
            </el-col>
          </el-row>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="20" :offset="2" style="padding-top: 10px">
          <el-table
            :id="kleerers"
            :data="filteredKleerers"
            border
            :default-sort="{ prop: 'kleerer', order: 'ascending' }"
            style="width: 100%"
          >
            <el-table-column prop="name" label="Kleerer"> </el-table-column>
            <el-table-column label="Aporte a Kleer Colombia" prop="input">
            </el-table-column>
            <el-table-column label="Meta anual">
              No disponible
            </el-table-column>
            <el-table-column label="Saldo pendiente">
              No disponible
            </el-table-column>
            <el-table-column label="Saldo a favor">
              No disponible
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

export default {
  name: "DynamicReports",
  components: { SafeBody },
  data() {
    return {
      loaded: false,
      kleerCo: {},
      kleerers: [],
      ingresos_kleerco: 0,
      filteredKleerers: [
        {
          kleerer: "",
          input: 0,
        },
      ],
      years: {
        disponibleYears: [],
        filteredYear: 2021,
      },
    };
  },
  created() {
    DynamicReportConnector.getData(this, (context) => {
      context.loaded = true;
      console.log(context.loaded);
      this.getDisponibleYears();
      this.filter();
      this.filterKleerers();
      console.log(this.years);
    });
  },
  methods: {
    filter() {
      this.filterKleerers();
      const totalIncome = this.kleerCo.meses.reduce((total, month) => {
        if (month.fecha.includes(this.years.filteredYear.toString())) {
          return total + parseFloat(month.ingresos);
        }
        return total + 0;
      }, 0);
      // this.filterKleerers()
      this.ingresos_kleerco = util.formatPrice(totalIncome);
    },

    filterKleerers() {
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
          return {
            name: kleerer.name,
            input: util.formatPrice(totalIncome),
          };
        })
        .filter((kleerer) => {
          return kleerer.input !== "$0,00";
        });
    },

    getDisponibleYears() {
      let actualYear = new Date().getFullYear();
      this.kleerCo.meses.forEach((date) => {
        if (date.fecha.includes(actualYear) || date.fecha.includes(actualYear - 1)) {
          console.log(`incluido ${actualYear}`);
          this.years.disponibleYears.push(actualYear--);
        }
      });
    },

    addObjective() {
      console.log("addObjective");
      DynamicReportConnector.addObjective(this, {objective: {
        amount: 1000000,
        kleerer_id: 5
      }});
    },
  },
};
</script>

<style scoped>
</style>
