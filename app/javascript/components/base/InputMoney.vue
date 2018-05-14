<template>
    <div class="el-input">
        <money class="el-input__inner" :name="name" :value="amount" @input="updateAmount($event)" v-bind="money" ></money>
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
      }
    }
  },
  methods: {
    updateAmount (amount) {
      this.$emit('input', amount)
    }
  }
}
</script>
