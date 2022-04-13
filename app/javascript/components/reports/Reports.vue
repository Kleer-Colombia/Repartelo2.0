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
				<input type="file" class="file-input" @change="loadData"><input>
			</el-col>
			<el-col :span="8" :offset="2">
				<el-button type="primary" @click="sendSaldos()">Carga de datos</el-button>
			</el-col>
			
		</el-row>
	</safe-body>
</template>

<style>
	.file-input {
		width: 400px !important;
		height: 50px !important;
	}
	.el-input__inner{
		height: 100% !important;
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
		saldos: []
      }
    },
    methods: {
		download (action) {
			reportConnector.downloadReport(this, action)
		},
		sendSaldos(){
			reportConnector.addExpensesPack(this, {saldos_pack: this.saldos})
		},
		transformData(data){
			const rows = data.split('\r\n')

			this.saldos = rows.map((row, key) => {
				if(key === 0) return
				if(row.length < 10) return
				console.log(row)
				return this.structData(row)
			});

			
		},
		structData(row){
			const cols = row.split(';')
			const gasto = {
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
