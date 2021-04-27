<template>
    <el-card class="box-card" :span="6">
        <div v-if="newExpense" slot="header" class="clearfix">
            <el-form label-position="left" label-width="100px">
                <el-form-item label="Descripción">
                    <el-input name="expenseDescription" v-model="expense.description"></el-input>
                </el-form-item>
                <el-form-item label="Monto">
                    <input-money name="expenseAmount" v-model="expense.amount"></input-money>
                </el-form-item>
                <el-form-item>
                    <el-button-group>
                        <el-button :plain="true" type="danger" size="mini" icon="el-icon-error"
                                   @click="showExpense()"></el-button>
                        <el-button id="saveExpense" type="primary" size="mini" icon="el-icon-success"
                                   @click="addExpense()"></el-button>
                    </el-button-group>
                </el-form-item>
            </el-form>
        </div>
        <div v-else slot="header" class="clearfix">
            <el-button type="primary" id="nuevo egreso" @click="showExpense()" :disabled="!editable">nuevo egreso
            </el-button>
        </div>

        <div v-for="expense in realExpenses" :key="expense.amount" class="text item">
            <el-row>
                <div style="float: left">
                    <el-button-group style="margin-right: 5px;">
                        <el-button v-bind:id="'removeExpense'+expense.amount" :disabled="!editable" :plain="true"
                                   size="mini" type="text" icon="el-icon-remove-outline"
                                   @click="removeExpense(expense.id)"></el-button>
                    </el-button-group>
                    <label>{{ expense.description }}</label>
                </div>
                <label style="float: right;">{{ formatPrice(expense.amount) }}</label>
            </el-row>
        </div>
    </el-card>
</template>

<script>
  import util from '../../model/util'
  import InputMoney from '../base/InputMoney'
  import balanceConnector from '../../model/balance_connector'
  import { EventBus } from '../../packs/application'

  export default {
    components: {InputMoney},
    name: 'expenses-admin',
    props: {
      editable: {
        type: [Boolean],
        default: true
      },
      allExpenses: {
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
        realExpenses: [],
        newExpense: false,
        expense: {
          description: '',
          amount: ''
        }
      }
    },
    created: function () {
      this.realExpenses = this.allExpenses

      EventBus.$on('updateExpenses', () => {
        balanceConnector.findExpenses(this, this.$route.params.id)
      })
    },
    methods: {
      showExpense () {
        this.newExpense = !this.newExpense
      },
      addExpense () {
        this.error = ''
        balanceConnector.addExpense(this, this.$route.params.id)
        this.newExpense = false
      },
      removeExpense (expenseId) {
        this.$confirm('¿Esta seguro de querer borrar este gasto?, no podrá recuperarlo si acepta.',
            'Cuidado!', {
              confirmButtonText: 'Aceptar',
              cancelButtonText: 'Cancelar',
              type: 'warning',
              center: true
            }).then(() => {
              this.error = ''
              balanceConnector.removeExpense(this, this.$route.params.id, expenseId)
            }).catch(() => {
              this.$message({
                type: 'info',
                message: 'verificalo bien ;-)'
              })
            })
      },
      formatPrice (value) {
        return util.formatPrice(value)
      }
    }
  }
</script>

<style scoped>

</style>
