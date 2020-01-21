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
	</safe-body>
</template>

<style>
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
        ]
      }
    },
    methods: {
      download (action) {
        reportConnector.downloadReport(this, action)
      }
    }
  }
</script>
