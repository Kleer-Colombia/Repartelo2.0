<template>
    <el-main>
        <el-button id="admin-coaching" type="primary" @click="dialogFormVisible = true">Registrar sesiones</el-button>

        <el-dialog :title="'Agregando registro para ' + kleerer.name" :visible.sync="dialogFormVisible">

            <span slot="footer" class="dialog-footer">
            <el-button @click="closeDialog(false)">Cancelar</el-button>
            <el-button type="primary" @click="addSaldo()">Guardar</el-button>
        </span>
        </el-dialog>
    </el-main>
</template>

<script>

    export default {
        name: "admin-coaching-log-button",
        props: {
            kleerer: {
                type: Object,
                default: ''
            }
        },
        data () {
            return {
                dialogFormVisible: false
            }
        },
        methods: {
            addSaldo () {

            },
            closeDialog (format) {
                this.dialogFormVisible = false
            }
        }
    }
</script>

<style scoped>

</style>