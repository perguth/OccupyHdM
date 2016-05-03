var fs = require('fs')

module.exports = function Database () {
  var filename = 'database.json'
  var data = {}
  if (!fs.existsSync(filename)) {
    data = '{"locations":[{"name":"Location 1","lat":48.74207,"lon":9.102263,"owner":"Fabian Kugler"},{"name":"Location 2","lat":48.740995,"lon":9.101709,"owner":"Per Guth"}]}'
    fs.writeFileSync(filename, data)
  } else data = JSON.parse(fs.readFileSync(filename))

  this.get = function (key) {
    if (!key) return data
    if (key) return data[key]
  }
  this.set = function (obj, key) {
    if (key) data[key] = obj
    else data = obj
    var plaintext = JSON.stringify(data)
    fs.writeFileSync(filename, plaintext)
  }
}
