<template>
    <el-main>
        <el-button type="primary" id='newCoachingSession' @click="visible = true">Nueva</el-button>

        <el-dialog tittle="Sesión de coaching" :visible.sync="visible" append-to-body>
            <el-form label-width="200px" id="form-coaching-session">
                <el-form-item label="Fecha">
                    <el-date-picker
                            v-model="coachingSession.date"
                            type="date"
                            v-bind:id="'date-coaching-session'"
                            placeholder="Fecha">
                    </el-date-picker>
                </el-form-item>
                <el-form-item label="Descripción">
                    <el-input type="textarea"
                              :rows="3"
                              name="description-coaching-session"
                              placeholder="Descripción"
                              v-model="coachingSession.description"></el-input>
                </el-form-item>
                <el-form-item label="Información complementaria">
                    <el-input name="complementary-coaching-session"
                              type="textarea"
                              :rows="2"
                              placeholder="Información complementaria"
                              v-model="coachingSession.complementary"></el-input>
                </el-form-item>

                <el-form-item label="Kleerers involucrados">
                    <el-row :gutter="10">
                        <el-checkbox-group v-model="coachingSession.kleerers">
                            <el-checkbox v-for="kleerer in kleerers"
                                         :label="kleerer.id"
                                         :key="kleerer.name"
                                         :id="'check-coaching-session' + kleerer.name"
                            >
                                {{kleerer.name}}
                            </el-checkbox>
                        </el-checkbox-group>

                    </el-row>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="save()">Guardar</el-button>
                </el-form-item>
            </el-form>
        </el-dialog>
    </el-main>

</template>

<script>

  import kleerersConnector from '../../model/kleerers_connector'
  import coachingSessionConnector from '../../model/coaching_session_connector'

  export default {
    name: 'coaching-log-form',
    props: {
      balanceId: {
        type: [String, Number]
      }
    },
    data () {
      return {
        kleerers: [],
        visible: false,
        coachingSession: {
          date: '',
          description: '',
          complementary: '',
          kleerers: []
        }
      }
    },
    created: function () {
      kleerersConnector.getKleerers(this, true)
    },
    methods: {
      save () {
        coachingSessionConnector.create(this, this.coachingSession, this.balanceId)
      }
    }
  }
</script>

<style scoped>

</style>
