/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue'
import App from '../app.vue'
import VueResource from 'vue-resource'
import ElementUI from 'element-ui'
import money from 'v-money'
import locale from 'element-ui/lib/locale/lang/en'
import 'element-ui/lib/theme-chalk/index.css'
import router from '../router'
Vue.config.productionTip = false
Vue.use(VueResource)
Vue.use(ElementUI, { locale })
Vue.use(money, {precision: 2})
Vue.http.options.emulateJSON = true

document.addEventListener('DOMContentLoaded', () => {
  const el = document.body.appendChild(document.createElement('application'))
  const app = new Vue({
    el,
    router,
    render: h => h(App)
  })
})
