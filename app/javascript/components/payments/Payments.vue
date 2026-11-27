<template>
  <SafeBody tittle="Pagos de facturas">
    <el-row>
      <el-col :span="22" :offset="1">
        <el-card class="box-card">
          <div slot="header" class="clearfix">
            <span v-if="lastSync" style="color: #909399;">
              Última lectura del Drive: {{ formatDateTime(lastSync.finishedAt) }}
              <span v-if="lastSync.error" style="color: #e6a23c;"> (error: {{ lastSync.error }})</span>
            </span>
            <span v-else-if="driveConfigured === false" style="color: #e6a23c;">
              El Drive de contabilidad no está configurado: se muestran solo las facturas ya cargadas.
            </span>
            <el-button style="float: right;" size="small" icon="el-icon-refresh" :loading="syncing"
                       :disabled="driveConfigured === false" @click="syncDrive()">
              Leer Drive ahora
            </el-button>
          </div>

          <el-tabs v-model="activeTab">
            <el-tab-pane label="Pendientes de pago" name="pending">
              <el-table :data="invoices" v-loading="loading" size="small" style="width: 100%"
                        empty-text="No hay facturas pendientes de pago">
                <el-table-column property="number" label="Número" width="120"></el-table-column>
                <el-table-column property="date" label="Emisión" width="105"></el-table-column>
                <el-table-column label="Vence" width="150">
                  <template slot-scope="scope">
                    <span>{{ scope.row.dueDate }}</span>
                    <el-tag v-if="daysOverdue(scope.row) > 0" size="mini" type="danger">
                      {{ daysOverdue(scope.row) }} días
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column property="client" label="Cliente" min-width="260"></el-table-column>
                <el-table-column label="Total" width="160" align="right">
                  <template slot-scope="scope">
                    {{ formatMoney(scope.row.total, scope.row.currency) }}
                  </template>
                </el-table-column>
                <el-table-column label="Balances" width="150">
                  <template slot-scope="scope">
                    <span v-if="scope.row.balances.length === 0" style="color: #909399;">—</span>
                    <router-link v-for="b in scope.row.balances" :key="b.id" :to="'/balance/' + b.id"
                                 style="margin-right: 6px;">#{{ b.id }}</router-link>
                  </template>
                </el-table-column>
                <el-table-column label="" width="130" align="center">
                  <template slot-scope="scope">
                    <el-button size="mini" type="primary" :id="'pay-' + scope.row.number"
                               @click="openDialog(scope.row)">Fue pagada</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </el-tab-pane>

            <el-tab-pane label="Pagadas" name="paid">
              <div style="margin-bottom: 10px;">
                Facturas emitidas en
                <el-select v-model="year" size="small" style="width: 100px;" @change="load()">
                  <el-option v-for="y in years" :key="y" :label="y" :value="y"></el-option>
                </el-select>
              </div>
              <el-table :data="invoices" v-loading="loading" size="small" style="width: 100%"
                        empty-text="No hay facturas pagadas en ese año">
                <el-table-column property="number" label="Número" width="120"></el-table-column>
                <el-table-column property="date" label="Emisión" width="105"></el-table-column>
                <el-table-column property="client" label="Cliente" min-width="220"></el-table-column>
                <el-table-column label="Total" width="150" align="right">
                  <template slot-scope="scope">{{ formatMoney(scope.row.total, scope.row.currency) }}</template>
                </el-table-column>
                <el-table-column label="Pagada el" width="110">
                  <template slot-scope="scope">
                    <span v-if="scope.row.payment.paidOn">{{ scope.row.payment.paidOn }}</span>
                    <el-tooltip v-else content="Marcada como pagada en Alegra (sin fecha)" placement="top">
                      <span style="color: #909399;">Alegra</span>
                    </el-tooltip>
                  </template>
                </el-table-column>
                <el-table-column label="Monto" width="140" align="right">
                  <template slot-scope="scope">
                    <span v-if="scope.row.payment.amount">{{ formatPrice(scope.row.payment.amount) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="Retefuente" width="120" align="right">
                  <template slot-scope="scope">{{ formatRetention(scope.row.payment.retefuente) }}</template>
                </el-table-column>
                <el-table-column label="Reteica" width="110" align="right">
                  <template slot-scope="scope">{{ formatRetention(scope.row.payment.reteica) }}</template>
                </el-table-column>
                <el-table-column label="Reteiva" width="110" align="right">
                  <template slot-scope="scope">{{ formatRetention(scope.row.payment.reteiva) }}</template>
                </el-table-column>
                <el-table-column label="" width="160" align="center">
                  <template slot-scope="scope">
                    <el-tooltip :disabled="!scope.row.lockedByClosedBalance"
                                content="Ya se usó en un balance cerrado" placement="top">
                      <span>
                        <el-button size="mini" :disabled="scope.row.lockedByClosedBalance"
                                   @click="openDialog(scope.row)">Editar</el-button>
                        <el-button size="mini" type="text" :disabled="scope.row.lockedByClosedBalance"
                                   @click="removePayment(scope.row)">Desmarcar</el-button>
                      </span>
                    </el-tooltip>
                  </template>
                </el-table-column>
              </el-table>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog :title="dialogTitle" :visible.sync="dialogVisible" width="560px">
      <div v-if="selected" style="margin-bottom: 15px; color: #606266;">
        {{ selected.client }} — total {{ formatMoney(selected.total, selected.currency) }}
        <div v-if="hasSuggestion" style="color: #909399; margin-top: 4px;">
          Retenciones precargadas con lo que figuraba en la factura; revisalas contra el soporte del pago.
        </div>
      </div>
      <el-form label-width="150px">
        <el-form-item label="Fecha de pago">
          <el-date-picker v-model="form.paidOn" type="date" value-format="yyyy-MM-dd" id="payment_date"
                          placeholder="Fecha"></el-date-picker>
        </el-form-item>
        <el-form-item :label="'Monto recibido' + (selected && selected.currency !== 'COP' ? ' (' + selected.currency + ')' : '')">
          <input-money name="paymentAmount" :amount="form.amount" @input="form.amount = $event"></input-money>
        </el-form-item>
        <el-form-item label="Retefuente (COP)">
          <input-money name="retefuente" :amount="form.retefuente" @input="form.retefuente = $event"></input-money>
        </el-form-item>
        <el-form-item label="Reteica (COP)">
          <input-money name="reteica" :amount="form.reteica" @input="form.reteica = $event"></input-money>
        </el-form-item>
        <el-form-item label="Reteiva (COP)">
          <input-money name="reteiva" :amount="form.reteiva" @input="form.reteiva = $event"></input-money>
        </el-form-item>
      </el-form>
      <div v-if="selected && selected.balances.length" style="color: #909399;">
        Las retenciones se van a aplicar en los balances abiertos que usan esta factura.
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogVisible = false">Cancelar</el-button>
        <el-button type="primary" id="savePayment" :loading="saving" @click="savePayment()">Guardar pago</el-button>
      </span>
    </el-dialog>
  </SafeBody>
</template>

<script>
  import SafeBody from '../base/SafeBody.vue'
  import InputMoney from '../base/InputMoney.vue'
  import paymentsConnector from '../../model/payments_connector'
  import util from '../../model/util'

  const RETENTIONS = ['retefuente', 'reteica', 'reteiva']

  function today () {
    const d = new Date()
    const pad = n => (n < 10 ? '0' : '') + n
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
  }

  export default {
    name: 'payments',
    components: { SafeBody, InputMoney },
    data () {
      const currentYear = new Date().getFullYear()
      return {
        activeTab: 'pending',
        year: currentYear,
        years: Array.from({ length: currentYear - 2019 }, (_, i) => currentYear - i),
        invoices: [],
        lastSync: null,
        driveConfigured: null,
        loading: false,
        syncing: false,
        saving: false,
        dialogVisible: false,
        selected: null,
        hasSuggestion: false,
        form: { paidOn: today(), amount: 0, retefuente: 0, reteica: 0, reteiva: 0 }
      }
    },
    computed: {
      dialogTitle () {
        if (!this.selected) return ''
        return (this.selected.payment ? 'Editar pago de ' : 'Pago de la factura ') + this.selected.number
      }
    },
    watch: {
      activeTab () {
        this.load()
      }
    },
    created () {
      this.load()
    },
    methods: {
      load () {
        this.invoices = []
        paymentsConnector.find(this, this.activeTab, this.year)
      },
      syncDrive () {
        paymentsConnector.syncDrive(this, () => this.load())
      },
      openDialog (invoice) {
        this.selected = invoice
        const payment = invoice.payment
        const suggested = invoice.suggestedRetentions || {}
        this.hasSuggestion = !payment && RETENTIONS.some(k => Number(suggested[k]) > 0)
        const source = payment || suggested
        const form = { paidOn: (payment && payment.paidOn) || today() }
        RETENTIONS.forEach(k => { form[k] = Number(source[k]) || 0 })
        if (payment && payment.amount) {
          form.amount = payment.amount
        } else if (invoice.currency === 'COP') {
          // Lo esperable: total menos retenciones.
          form.amount = invoice.total - form.retefuente - form.reteica - form.reteiva
        } else {
          form.amount = invoice.total
        }
        this.form = form
        this.dialogVisible = true
      },
      savePayment () {
        if (!this.form.paidOn) {
          this.$message({ type: 'warning', message: 'Falta la fecha de pago' })
          return
        }
        if (!(Number(this.form.amount) > 0)) {
          this.$message({ type: 'warning', message: 'El monto recibido tiene que ser mayor a cero' })
          return
        }
        const payment = { paidOn: this.form.paidOn, amount: Number(this.form.amount) }
        RETENTIONS.forEach(k => { payment[k] = Math.abs(Number(this.form[k]) || 0) })
        paymentsConnector.register(this, this.selected.number, payment, () => {
          this.dialogVisible = false
          this.load()
        })
      },
      removePayment (invoice) {
        this.$confirm('La factura ' + invoice.number + ' vuelve a Pendientes y sus retenciones se sacan de los balances abiertos. ¿Seguimos?',
                      'Desmarcar pago', { confirmButtonText: 'Desmarcar', cancelButtonText: 'Cancelar', type: 'warning' })
          .then(() => paymentsConnector.remove(this, invoice.number, () => this.load()))
          .catch(() => {})
      },
      daysOverdue (invoice) {
        if (!invoice.dueDate) return 0
        const due = new Date(invoice.dueDate + 'T00:00:00')
        return Math.floor((new Date() - due) / 86400000)
      },
      formatMoney (value, currency) {
        return (currency && currency !== 'COP' ? currency + ' ' : '') + util.formatPrice(value)
      },
      formatPrice (value) {
        return util.formatPrice(value)
      },
      formatRetention (value) {
        return Number(value) > 0 ? util.formatPrice(value) : '—'
      },
      formatDateTime (value) {
        return value ? new Date(value).toLocaleString('es-CO') : ''
      }
    }
  }
</script>
