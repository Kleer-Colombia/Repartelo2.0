<template>
    <el-card class="box-card">
        <el-row>
            <el-col :offset="1" :span="2">
                <div class="grid-content">
                    <p>ID: {{idB}}</p>
                </div>
            </el-col>
            <el-col :span="4">
                <div v-if="editMode" class="grid-content">
                    <p>Cliente:  <el-input name="client"
                                           placeholder="Cliente"
                                           v-model="clientB"></el-input></p>
                </div>
              <div v-else class="grid-content">
                <p>Cliente: <span id="client">{{clientB}}</span></p>
              </div>
            </el-col>
            <el-col :span="4">
              <div v-if="editMode" class="grid-content">
                <p>Project: <el-input name="client"
                                      placeholder="Cliente"
                                      v-model="projectB"></el-input></p>
              </div>
                <div v-else class="grid-content">
                    <p>Project: <span id="project">{{projectB}}</span></p>
                </div>
            </el-col>
            <el-col :span="2">
              <div v-if="editMode" class="grid-content">
                <p>Fecha: <el-date-picker
                    v-model="dateB"
                    type="date"
                    v-bind:id="'date'"
                    placeholder="Fecha">
                </el-date-picker></p>
              </div>
                <div v-else class="grid-content">
                    <p>Fecha: <span id="date">{{dateB}}</span></p>
                </div>
            </el-col>
            <el-col :span="4">
              <div v-if="editMode" class="grid-content">
                <p>Description: <el-input type="textarea"
                                          :rows="3"
                                          placeholder="Descripción"
                                          name="description"
                                          v-model="descriptionB"></el-input></p>
              </div>
                <div v-else class="grid-content">
                    <p>Description: <span id="description">{{descriptionB}}</span></p>
                </div>
            </el-col>
            <el-col :span="3" v-if="balance_typeB === 'standard-international'">
                <div class="grid-content">
                    <p>Retención a aplicar: <span id="retencion">{{retencionB}}</span></p>
                </div>
            </el-col>
            <el-col :span="3" v-else>

            </el-col>
            <el-col :span="4">
              <el-button v-if="editMode" type="success" id="Guardar" @click="saveBalance()"
                         :disabled="!editableB">
                Guardar
              </el-button>
              <el-button v-else type="primary" id="Editar" @click="editBalance()"
                         :disabled="!editableB">
                Editar
              </el-button>
                <el-button type="danger" id="Borrar" @click="deleteBalance()"
                           :disabled="!editableB">
                  Borrar
                </el-button>
            </el-col>

        </el-row>
    </el-card>
</template>
<style>
    .box-card {
        margin-left: 10px;
        margin-right: 10px;
        margin-top: 10px;
    }
</style>
<script>

  import balanceConnector from '../../model/balance_connector'

  export default {
    components: {

    },
    name: 'propertiesBalance',
    props: {
      id: {
        type: Number,
        default: 0
      },
      client: {
        type: String,
        default: ''
      },
      project: {
        type: String,
        default: ''
      },
      description: {
        type: String,
        default: ''
      },
      balance_type: {
        type: String,
        default: ''
      },
      date: {
        type: [String, Date],
        default: ''
      },
      retencion: {
        type: [Number, String],
        default: 0
      },
      editable: {
        type: Boolean,
        default: true
      }
    },
    data () {
      return {
        idB: '',
        clientB: '',
        projectB: '',
        descriptionB: '',
        balance_typeB: '',
        retencionB: 0,
        dateB: null,
        editableB: true,
        editMode: false
      }
    },
    created: function () {
      this.idB = this.id
      this.clientB = this.client
      this.projectB = this.project
      this.descriptionB = this.description
      this.balance_typeB = this.balance_type
      this.retencionB = this.retencion
      this.dateB = this.date
      this.editableB = this.editable
    },
    methods: {
      deleteBalance () {
        this.$confirm('Esto borrará permanentemente todos los datos asociados a este balance, ¿Desea continuar?',
          'Cuidado!', {
            confirmButtonText: 'Aceptar',
            cancelButtonText: 'Cancelar',
            type: 'warning',
            center: true
          }).then(() => {
            balanceConnector.deleteBalance(this, this.$route.params.id)
          }).catch(() => {
            this.$message({
              type: 'info',
              message: 'Borrado cancelado'
            })
          })
      },
      editBalance () {
        this.editMode = true
      },
      saveBalance () {
        balanceConnector.editBalance(this, {
          id: this.idB,
          client: this.clientB,
          project: this.projectB,
          description: this.descriptionB,
          date: this.dateB
        })
        this.editMode = false
      }
    }
  }
</script>
