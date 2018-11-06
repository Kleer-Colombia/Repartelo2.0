<template>
    <el-card class="box-card" :span="6">
        <div v-if="newIncome" slot="header" class="clearfix">
            <el-form label-position="left" label-width="100px">
                <el-form-item label="Descripción">
                    <el-input name="incomeDescription" v-model="income.description"></el-input>
                </el-form-item>
                <el-form-item label="Monto">
                    <input-money name="incomeAmount" v-model="income.amount"></input-money>
                </el-form-item>
                <el-form-item>
                    <el-button-group>
                        <el-button :plain="true" type="danger" size="mini" icon="el-icon-error"
                                   @click="showIncome()"></el-button>
                        <el-button id="saveIncome" type="primary" size="mini" icon="el-icon-success"
                                   @click="addIncome()"></el-button>
                    </el-button-group>
                </el-form-item>
            </el-form>
        </div>
        <div v-else slot="header" class="clearfix">
            <el-button type="primary" id="nuevo ingreso" @click="showIncome()" :disabled="!editable"> nuevo ingreso
            </el-button>
        </div>

        <div v-for="income in realIncomes" :key="income.amount" class="text item">
            <el-row>
                <div style="float: left">
                    <el-button-group style="margin-right: 5px;">
                        <el-button v-bind:id="'removeIncome'+income.amount" :disabled="!editable"
                                   :plain="true" size="mini" type="text" icon="el-icon-remove-outline"
                                   @click="removeIncome(income.id)"></el-button>
                    </el-button-group>
                    <label>{{ income.description }}</label>
                </div>
                <label style="float: right;">{{ formatPrice(income.amount) }}</label>
            </el-row>
        </div>
    </el-card>
</template>

<script>
  import util from '../../model/util'
  import InputMoney from '../base/InputMoney'
  import balanceConnector from '../../model/balance_connector'

  export default {
    components: {InputMoney},
    name: 'incomes-admin',
    props: {
      editable: {
        type: [Boolean],
        default: true
      },
      allIncomes: {
        type: [Array],
        default: []
      },
      value: {
        type: [Number, String],
        default: 0
      }
    },
    data () {
      return {
        realIncomes: [],
        newIncome: false,
        income: {
          description: '',
          amount: ''
        }
      }
    },
    created: function () {
      this.realIncomes = this.allIncomes
    },
    methods: {
      showIncome () {
        this.newIncome = !this.newIncome
      },
      addIncome () {
        this.error = ''
        balanceConnector.addIncome(this, this.$route.params.id)
        this.newIncome = false
      },
      removeIncome (incomeId) {
        this.error = ''
        balanceConnector.removeIncome(this, this.$route.params.id, incomeId)
      },
      formatPrice (value) {
        return util.formatPrice(value)
      }
    }
  }
</script>

<style scoped>

</style>
