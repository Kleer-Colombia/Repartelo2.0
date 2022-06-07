<template>
	<safe-body tittle="Reportes">
		<el-row :gutter="20">
			<el-col :span="20" :offset="2">
				<br>
				<el-table :id='reportes'
				          :data="reports"
				          style="width: 100%">
					<el-table-column
									prop="name"
									label="Nombre"
									min-width="280"
					>
					</el-table-column>
					<el-table-column
									prop="action"
									label=""
									min-width="80"
					>
						<template slot-scope="scope">
              <span :id="'download'+scope.row.name">
                <el-button :plain="true" type="primary" @click="download(scope.row.action)">Descargar</el-button>
              </span>
						</template>
					</el-table-column>
				</el-table>
			</el-col>
		</el-row>
		<el-row>
			<el-col :span="15" :offset="2">
				<h2>Cargue masivo de datos</h2>
			</el-col>
			
			<el-col :span="8" :offset="2">
				<input type="file" class="file-input" @change="loadData" />
			</el-col>
			<el-col :span="8" :offset="2">
				<el-button type="primary" @click="sendSaldos()" :disabled="loading">Carga de datos</el-button>
			</el-col>
			<el-col :span="15" :offset="2">
				<h3>Reporte de carga</h3>
				<div v-if="!report" v-loading="loading">
					Sin reporte
				</div>
				<div v-if="report" v-loading="loading">
				    Saldos agregados {{report.saldos_added}}
					<br />
					Impuestos agregados {{report.taxes_added}}
					<br />
					Errores {{report.errors}}
					<br />
					Detalles:
					<div v-for="error in report.detail_errors" :key="error">
						<ul>{{error}}</ul>
					</div>
				</div>
			</el-col>
			
		</el-row>
	</safe-body>
</template>

<style>
	.file-input::-webkit-file-upload-button {
		width: 150px !important;
		height: 30px !important;
	}
	.el-table .normal-row {
		background: white;
	}
	
	.el-table .success-row {
		background: #f0f9eb;
	}
	
	.el-table__header {
		margin-bottom: 0px;
	}
</style>

<script>

  import reportConnector from '../../model/report_connector'
  import SafeBody from '../base/SafeBody.vue'

  export default {

    components: {
      SafeBody
    },
    data () {
      return {
        reports: [
          {
            name: 'Reporte Financiero',
            action: '/financial'
          },
          {
            name: 'Reporte de gastos en balances',
            action: '/expenses'
          },
          {
            name: 'Saldos',
            action: '/saldos'
          }
        ],
		saldos: [],
		report: null,
		loading: false
      }
    },
    methods: {
		download (action) {
			reportConnector.downloadReport(this, action)
		},
		sendSaldos(){
			this.$confirm(`¿Está seguro de querer cargar este archivo?`, {
              confirmButtonText: 'Aceptar',
              cancelButtonText: 'Cancelar',
              type: 'warning',
              center: true
            }).then(()=> {
				this.loading = true
				reportConnector.addExpensesPack(this, {saldos_pack: this.saldos})
			}).catch(()=> {
				this.$message({
					type: 'info',
					message: 'Operación cancelada'
				})
			})
			
		},
		transformData(data){
			const rows = data.split('\r\n')

			this.saldos = rows.map((row, key) => {
				if(key === 0) return
				if(row.length < 10) return
				return this.structData(row, key)
			});

			
		},
		structData(row, key){
			const cols = row.split(';')
			const gasto = {
				id: key + 1,
				date: cols[1],
				kleerer: cols[3],
				concept: cols[4],
				amount: cols[5],
				reference: cols[6]
			}
			return gasto
		},
		loadData (e) {
			
		  	const reader = new FileReader()
            reader.onload = (e) => {
                this.transformData(e.target.result)
            }
        	reader.readAsText(e.target.files[0])
	  	},
		
    }
  }
</script>
