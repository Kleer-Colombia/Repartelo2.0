<template>
    <el-main>
        <el-button  type="primary" @click="dialogFormVisible = true">Administrar log</el-button>

        <el-dialog title="Administrar log de coaching" :visible.sync="dialogFormVisible">

        <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cerrar</el-button>
        </span>
        </el-dialog>
    </el-main>
</template>

<script>
  export default {
    name: 'coaching-distribution',
    props: {
      balance: {
        type: String,
        default: ''
      }
    },
    data () {
      return {
        dialogFormVisible: false,
        balance_id: this.balance.id
      }
    },
    methods: {
      closeDialog (format) {
        this.dialogFormVisible = false
      }
    }
  }

</script>

<style scoped>

</style>
