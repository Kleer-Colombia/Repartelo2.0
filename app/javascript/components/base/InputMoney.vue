<template>
    <div class="el-input">
        <money class="el-input__inner"
               :style="getFormat(format)"
               :name="name" :value="amount" @input="updateAmount($event)" v-bind="money" ></money>
    </div>
</template>
<style>
  input[type=number]::-webkit-inner-spin-button, 
  input[type=number]::-webkit-outer-spin-button { 
    -webkit-appearance: none; 
    margin: 0; 
  }
</style>

<script>
export default {
  props: {
    amount: {
      type: [Number, String],
      default: 0
    },
    format: {
      type: String,
      default: "white"
    },
    name: {
      type: String
    }
  },
  data () {
    return {
      money: {
        decimal: ',',
        thousands: '.',
        prefix: '$ ',
        suffix: '',
        precision: 2,
        masked: false
      },
      formats: {
          white: "",
          income: "border:2px solid #27d401",
          expense: "border:2px solid #df4a30"
      }
    }
  },
  methods: {
    updateAmount (amount) {
      this.$emit('input', amount)
    },
    getFormat(format) {
      return this.formats[format]
    }
  }
}
</script>
