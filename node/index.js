var restify = require('restify')
var Database = require('./database')
require('console-stamp')(console)

var db = new Database()
console.log(db.get())

var server = restify.createServer({
  name: 'OccupyHdM-REST-backend',
  version: '0.0.0'
})
server.use(restify.acceptParser(server.acceptable))
server.use(restify.queryParser())
server.use(restify.bodyParser())

// get all locations
server.get('/goals', function (req, res, next) {
  res.send(db.get())
  next()
})

// claim a location
server.get('/own/:location/:name', function (req, res, next) {
  var locationName = req.params.location.replace('%20', ' ')
  var userName = req.params.name
  var data = db.get('locations')

  for (var id in data) {
    if (data[id].name !== locationName) continue

    data[id].owner = userName
    db.set('locations', data)
    break
  }
  next()
})

server.listen(8080, function () {
  console.log('%s listening at %s', server.name, server.url)
})
