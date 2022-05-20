<template>
    <el-card class="box-card" :span="6">
        <div v-if="newClearing" slot="header" class="clearfix">
            <el-form label-position="left" label-width="100px">
                <el-form-item label="Descripción">
                    <el-input  type="textarea" name="clearingDescription" v-model="clearing.description"></el-input>
                </el-form-item>
                <el-form-item label="Porcentaje">
                  <el-input-number
                    class="decimal-input"
                    size="medium"
                    v-model="percentageSelector.digit"
                    :max="percentageSelector.max"
                    :min="percentageSelector.min"
                    :step="0.01"
                    @change="calculatePercentage()"
                    >
				          </el-input-number>
                </el-form-item>
                <el-form-item label="País destino">
                    <el-select v-model="clearing.countryId" placeholder="País">
                        <el-option
                            v-for="country in countries"
                            :key="country.id"
                            :label="country.name"
                            :value="country.id">
                        </el-option>
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button-group>
                        <el-button :plain="true" type="danger" size="mini" icon="el-icon-error"
                                  @click="showClearing()"></el-button>
                        <el-button id="saveCLearing" type="primary" size="mini" icon="el-icon-success"
                                  @click="addClearing()"></el-button>
                    </el-button-group>
                </el-form-item>
            </el-form>
        </div>
        <div v-else slot="header" class="clearfix">
            <el-button type="primary" id="nuevo egreso" @click="showClearing()" :disabled="!editable">nuevo clearing
            </el-button>
        </div>

        <div v-for="clearing in realClearings" :key="clearing.amount" class="text item">
            <el-row>
                <div style="float: left">
                    <el-button-group style="margin-right: 5px;">
                        <el-button v-bind:id="'removeClearing'+clearing.percentage" :disabled="!editable" :plain="true"
                                  size="mini" type="text" icon="el-icon-remove-outline"
                                  @click="removeClearing(clearing.id)"></el-button>
                    </el-button-group>
                    <label>{{ countries[clearing.country_id - 1].name }}</label>
                </div>
                <label style="float: right;">{{ `${ preutilidad <= 0 ? `${clearing.percentage * 100}%` : calculateOneClearing(clearing)} ` }}</label>
                <!-- <label style="float: right;">{{ `${clearing.percentage * 100}%` }}</label> -->
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
    name: 'clearing-admin',
    props: {
      editable: {
        type: [Boolean],
        default: true
      },
      allClearings: {
        type: [Array],
        default: []
      },
      value: {
        type: [Number, String],
        default: 0
      },
      countries: {
        type: [Array],
        default: []
      },
      preutilidad: {
        type: [Number],
        default: 0
      }
    },
    data () {
      return {
        realClearings: [],
        newClearing: false,
        clearing: {
          description: '',
          percentage: '',
          countryId: '',
        },
        percentageSelector: {
            max: 100,
		    min: 0,
		    digit: 0,
	    },
      }
    },
    created: function () {
      this.realClearings = this.allClearings

      EventBus.$on('updateClearings', () => {
        balanceConnector.findClearings(this, this.$route.params.id)
      })
    },
    methods: {
      showClearing () {
        this.newClearing = !this.newClearing
      },
      addClearing () {
        this.error = ''
        balanceConnector.addClearing(this, this.$route.params.id)
        this.newClearing = false
      },
      removeClearing (ClearingId) {
        this.$confirm('¿Esta seguro de querer borrar este clearing?, no podrá recuperarlo si acepta.',
            'Cuidado!', {
              confirmButtonText: 'Aceptar',
              cancelButtonText: 'Cancelar',
              type: 'warning',
              center: true
            }).then(() => {
              console.log('va piola', ClearingId)
              this.error = ''
              balanceConnector.removeClearing(this, this.$route.params.id, ClearingId)
            }).catch((error) => {
              console.log('error', error)
              this.$message({
                type: 'info',
                message: 'verificalo bien ;-)'
              })
            })
      },
      calculateOneClearing(clearing){
        return this.formatPrice(clearing.percentage * this.preutilidad)
      },
      formatPrice (value) {
        return util.formatPrice(value)
      },
      calculatePercentage(){
          this.clearing.percentage = this.percentageSelector.digit * 0.01
      }
    }
  }
</script>

<style scoped>
.decimal-input{
  width: 90%;
}
</style>
<style >
.el-input__inner{
  margin-left: 40px;
  margin-right: 20px !important;
  margin-top: 2px !important
}
.el-input--suffix{
  margin-left: -35px;
}
.el-input__suffix-inner{
  margin-left: 40px !important;
}
</style>
