var fs = require('fs')

module.exports = function Database () {
  var filename = 'database.json'
  try {
    fs.accessSync(filename, fs.F_OK)
  } catch (e) {
    data = '{"locations":[{"name":"Location1","lat":48.74207,"lon":9.102263,"owner":"Fabian Kugler"},{"name":"Location2","lat":48.740995,"lon":9.101709,"owner":"Per Guth"}]}'
    fs.writeFileSync(filename, data)
  }
  var data = JSON.parse(fs.readFileSync(filename).toString())

  this.get = function () {
    return data
  }
  this.set = function (data) {
    var plaintext = JSON.stringify(data)
    fs.writeFileSync(filename, plaintext)
    console.log('saved data:\n', data)
  }
}
