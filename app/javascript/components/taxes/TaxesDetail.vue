<template>

<el-main>
  <el-row :gutter="20" justify="center" type="flex">
      <el-col  :span="16" :offset="4" >
        <el-col :span="5">
          <div class="grid-content">
            <h3>En reserva: <br> <span v-html="addColorToValue(summary.reserved, 'reserva')"></span></h3>
          </div>
        </el-col>
        <el-col :span="5">
          <div class="grid-content">
            <h3>Pagados: <br> <span v-html="addColorToValue(summary.payed, 'pagados')"></span></h3>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="grid-content">
            <h3>Total: <br> <span v-html="addColorToValue(summary.total, 'total')"></span></h3>
          </div>
        </el-col>
      </el-col>
    </el-row>
  <el-row>
    <el-col :span="22" :offset="1" >
      <el-table
              :data="taxDetailPaged"
              style="width: 100%;">
        <el-table-column
                label="Fecha"
                prop="date"
                min-width="60">
        </el-table-column>
        <el-table-column
                label="Monto"
                prop="amount"
                min-width="60">
          <template slot-scope="scope">
            <span v-html="addColorToValue(scope.row.amount, 'ID')"></span>
          </template>
        </el-table-column>

        <el-table-column
                label="Cliente"
                prop="balance.client"
                min-width="80">
        </el-table-column>
        <el-table-column
                label="Descripción"
                prop="balance"
                min-width="180">
          <template slot-scope="scope">
            <span>
               {{scope.row.balance.project}} <br> {{scope.row.balance.description}}
            </span>
          </template>
        </el-table-column>

        <el-table-column
                label="Balance"
                prop="balance">
          <template slot-scope="scope">
            <router-link class="el-button el-button--text" :to="'/balance/'+ scope.row.balance.id ">
              Balance {{scope.row.balance.id}}</router-link>
          </template>
        </el-table-column>
      </el-table>
    </el-col>
  </el-row>
  <el-row  justify="center" type="flex">
    <el-col :span="12" :offset="6" justify="center" type="flex">
      <el-pagination
              background
              layout="prev, pager, next"
              :total="taxDetail.length"
              :page-size="pageSize"
              @current-change="currentPageChange">
      </el-pagination>
    </el-col>
  </el-row>
</el-main>

</template>

<style>

</style>

<script>

  import util from '../../model/util'
  import router from '../../router'

  export default {

    props: {
      taxDetail: {
        type: Array,
        default: ''
      }
    },
    data () {
      return {
        saldo: {},
        pageSize: 10,
        page: 0,
        taxDetailPaged: [],
        summary: {
          reserved: 0,
          payed: 0,
          total: 0
        }
      }
    },
    mounted () {
      this.paginate()
      this.summarize()
    },
    methods: {
      summarize () {
        this.summary = this.taxDetail.reduce(function (summary, tax) {
          let amount = parseFloat(tax.amount)
          if (amount > 0) {
            summary.reserved += amount
          } else {
            summary.payed += amount
          }
          return summary
        }, {reserved: 0, payed: 0, total: 0})
        this.summary.total = this.summary.reserved - this.summary.payed
      },
      currentPageChange (page) {
        this.page = page - 1
        this.paginate()
      },
      paginate () {
        this.taxDetailPaged = this.taxDetail.slice(this.page * this.pageSize, (this.page + 1) * this.pageSize)
      },
      addColorToValue (value, id) {
        var color = 'black'
        if (value) {
          if (Number(value) < 0) {
            color = 'red'
          } else {
            color = 'green'
          }
          value = util.formatPrice(value)
        }
        return '<span style="color:' + color + '" id="' + id + '">' +
          value +
          '</span>'
      },
      routeTo (route) {
        router.push(route)
      }
    }
  }
  </script>
