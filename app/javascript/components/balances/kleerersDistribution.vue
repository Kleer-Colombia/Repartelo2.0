<template>
    <el-col :span="12" :offset="1">
        <br>
        <el-row :gutter="10" v-for="kleerer in distribution.kleerers" :key="kleerer.id"
                :id="'percentage_' + kleerer.name">
            <el-col :span="6">
                <el-checkbox-button
                        v-model="kleerer.selected"
                        :label="kleerer.id"
                        :key="kleerer.name"
                        :id="'check' + kleerer.name"
                        :disabled="!editable"
                        @change="selectKleerer(kleerer)">
                    <span>{{ kleerer.name }}</span> -
                    <span style="font-size: 12px">{{ kleerer.option }}</span>
                </el-checkbox-button>
            </el-col>
            <el-col :offset="1" :span="8">
                <div v-show="kleerer.selected">
                    <el-progress :percentage="kleerer.value" :stroke-width="15"
                                 style="margin-top: 12px;"></el-progress>
                </div>
            </el-col>
            <el-col :offset="1" :span="4">
                <div v-show="kleerer.selected">
                    <el-input @change="formatValue(kleerer,$event)" v-model="kleerer.value"
                              :id="'inputPercentage' + kleerer.name" :disabled="!editable">
                    </el-input>
                </div>
            </el-col>
        </el-row>
        <el-row :gutter="10">
            <el-col :offset="8" :span="4">
                <el-button type="success" id="Distribuir" @click="distribute()"
                           :disabled="!editable">Distribuir
                </el-button>
            </el-col>
        </el-row>
    </el-col>
</template>

<script>

  import balanceConnector from '../../model/balance_connector'
  import dealer from '../../model/kleerers_distributions'

  export default {
    name: 'kleerers-distribution',
    props: {
      editable: {
        type: [Boolean],
        default: true
      },
      balancePercentages: {
        type: [Array],
        default: []
      }
    },
    data () {
      return {
        distribution: {
          kleerers: [],
          percentageCached: []
        }
      }
    },
    created: function () {
      balanceConnector.getKleerers(this)
    },
    watch: {
      balancePercentages: function (newVal) {
        this.distribution.percentageCached = newVal
        this.updateKleerersSelecteds(this)
        this.$forceUpdate()
      }
    },
    methods: {
      updateKleerersSelecteds (context) {
        var percentages = context.distribution.percentageCached
        var kleerers = context.distribution.kleerers
        for (var i = 0; i < percentages.length; i++) {
          for (var j = 0; j < kleerers.length; j++) {
            if (percentages[i].kleerer_id === kleerers[j].id) {
              kleerers[j].selected = true
              kleerers[j].value = parseFloat(percentages[i].value)
            }
          }
        }
      },

      selectKleerer (kleerer) {
        dealer.setPercentage(this.distribution.kleerers)
        this.updateKleerersPercentages()
        // clean v-model distribution
        this.$emit('input', null)
        this.$forceUpdate()
      },
      formatValue (kleerer, value) {
        if (kleerer.value >= 100) {
          kleerer.value = 100
        }
        if (kleerer.value < 0) {
          kleerer.value = 0
        }
        kleerer.value = Math.round(kleerer.value * 100) / 100
        this.updateKleerersPercentages()
        // clean v-model distribution
        this.$emit('input', null)
        this.$forceUpdate()
      },
      updateKleerersPercentages () {
        var kleerersSelected = dealer.prepareSelecteds(this.distribution.kleerers)
        balanceConnector.updateKleerersPercentages(this, this.$route.params.id, kleerersSelected)
      },
      distribute () {
        if (dealer.areValidPercentage(this.distribution.kleerers)) {
          var data = {
            balanceId: this.$route.params.id
          }
          balanceConnector.distribute(this, data)
        } else {
          this.$message({
            type: 'error',
            message: 'la suma de los porcentajes de distribucion no suma 100, verificalo bien ;-)'
          })
        }
      }
    }
  }
</script>

<style scoped>

</style>
