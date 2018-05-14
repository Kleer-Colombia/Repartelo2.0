export default {

  setPercentage (kleerers) {
    var selecteds = this.findSelecteds(kleerers)
    var percentage = parseFloat((100 / selecteds.length).toFixed(2))
    for (var i = 0; i < selecteds.length; i++) {
      selecteds[i].value = percentage
    }
  },
  findSelecteds (kleerers) {
    var selecteds = []
    for (var i = 0; i < kleerers.length; i++) {
      if (kleerers[i].selected) {
        selecteds.push(kleerers[i])
      }
    }
    return selecteds
  },
  prepareSelecteds (kleerers) {
    var selecteds = []
    for (var i = 0; i < kleerers.length; i++) {
      if (kleerers[i].selected) {
        var kleerer = {}
        kleerer['id'] = kleerers[i].id
        kleerer['value'] = kleerers[i].value
        selecteds.push(kleerer)
      }
    }
    return selecteds
  },
  areValidPercentage (kleerers) {
    var total = 0
    for (var i = 0; i < kleerers.length; i++) {
      if (kleerers[i].selected) {
        total += kleerers[i].value
      }
    }
    return total === 100
  }
}
