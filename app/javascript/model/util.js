import auth from './auth'

// URLs dentro de textos libres (conceptos, descripciones, referencias).
// Antes vivía duplicada en TaxesDetail/TaxesDetailByYear como `urlify`.
const URL_IN_TEXT = /((?:(http|https|Http|Https|rtsp|Rtsp):\/\/(?:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,64}(?:\:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,25})?\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\:\d{1,5})?)(\/(?:(?:[a-zA-Z0-9\;\/\?\:\@\&\=\#\~\-\.\+\!\*\'\(\)\,\_])|(?:\%[a-fA-F0-9]{2}))*)?(?:\b|$)/gi

const util = {
    // --- HTML seguro para v-html -------------------------------------------
    // Todo texto que venga de datos (conceptos, referencias, descripciones,
    // montos) pasa por escapeHtml antes de ir a un v-html; los links se
    // arman acá, solo con http/https. Evita XSS almacenado.
    escapeHtml(value) {
        if (value === null || value === undefined) return ''
        return String(value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
    },
    // true solo si el texto completo es una URL http(s) válida.
    isHttpUrl(str) {
        try {
            const url = new URL(String(str).trim())
            return url.protocol === 'http:' || url.protocol === 'https:'
        } catch (e) {
            return false
        }
    },
    safeLink(url, label) {
        return '<a target="_blank" rel="noopener noreferrer" href="' + this.escapeHtml(url) + '">' +
            this.escapeHtml(label === undefined ? url : label) + '</a>'
    },
    // Escapa el texto y convierte en link las URLs que contenga. Las que no
    // traen protocolo (ej. "kleer.la/x") se linkean como http://; otros
    // protocolos (rtsp:, etc.) quedan como texto.
    linkify(text) {
        const raw = text === null || text === undefined ? '' : String(text)
        let html = ''
        let last = 0
        raw.replace(URL_IN_TEXT, (match, ...args) => {
            const offset = args[args.length - 2]
            html += this.escapeHtml(raw.slice(last, offset))
            if (this.isHttpUrl(match)) {
                html += this.safeLink(match)
            } else if (!/^[a-z][a-z0-9+.-]*:/i.test(match)) {
                html += this.safeLink('http://' + match, match)
            } else {
                html += this.escapeHtml(match)
            }
            last = offset + match.length
            return match
        })
        return html + this.escapeHtml(raw.slice(last))
    },
    // Monto con color (verde/rojo). `id` es siempre una constante del template.
    colorValue(value, id) {
        let color = 'black'
        let text = value
        if (value) {
            color = Number(value) < 0 ? 'red' : 'green'
            text = this.formatPrice(value)
        }
        return '<span style="color:' + color + '" id="' + this.escapeHtml(id) + '">' +
            this.escapeHtml(text) + '</span>'
    },
    formatReference(reference) {
        if (this.isHttpUrl(reference)) {
            return 'Referencia: ' + this.safeLink(String(reference).trim(), ' aquí ')
        }
        return '<span>Ref: ' + this.linkify(reference) + '</span>'
    },
    // ------------------------------------------------------------------------
    // The object to be passed as a header for authenticated requests
    validURL(str) {
        var regex = /(http|https):\/\/(\w+:{0,1}\w*)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%!\-\/]))?/;
        return regex.test(str)
    },
    getAuthHeader() {
        return 'Bearer ' + this.checkAuth('access_token')
    },
    saveFeatureFlag(featureFlag) {
        localStorage.setItem('feature-flag', JSON.stringify(featureFlag))
    },
    checkFlag(flag) {
        return JSON.parse(localStorage.getItem('feature-flag'))[flag]
    },
    checkAuth() {
        return localStorage.getItem('access_token')
    },
    formatPrice(value) {
        let val = (value / 1).toFixed(2).replace('.', ',')
        val = val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
        return '$' + val
    },
    getPercentage(value, total) {
        return (value / total * 100).toFixed(2)
    },
    apiUrl() {
        return this.baseUrl() + 'api/v1'
    },
    baseUrl() {
        let url = window.location.protocol + '//' + window.location.hostname
        if (window.location.port !== '') {
            url = url + ':' + window.location.port + '/'
        } else {
            url = url + '/'
        }
        return url
    },
    processErrorMsgs(error, context) {
        if (error.response) {
            if (error.response.status === 401) {
                this.manageAuthError(error, context)
            } else if (error.response.status === 404) {
                this.manageSrvNotFoundError(context)
            } else {
                context.$message({
                    type: 'error',
                    message: 'Error: ' + error.response.status + ':' + error.response.data.message,
                    duration: 6000
                })
            }
        } else {
            this.manageSrvNotFoundError(error, context)
        }
    },
    manageAuthError(error, context) {
        auth.logout()
        context.$message({
            type: 'error',
            message: 'Error de sesión: ' + error.response.data.message,
            duration: 6000
        })
    },
    manageSrvNotFoundError(error, context) {
        context.$message({
            type: 'error',
            message: 'Uyyyy algo paso: ' + error,
            duration: 6000
        })
    }
}
export default util