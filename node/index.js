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

server.get('/', function (req, res, next) {
  res.send('This is the API for the PMA application.')
})

// get all locations
server.get('/goals', function (req, res, next) {
  res.send(db.get())
})

// claim a location
server.get('/own/:location/:name', function (req, res, next) {
  var locationName = req.params.location.replace('%20', ' ')
  var userName = req.params.name
  var data = db.get()

  for (var id in data.locations) {
    console.log('id', id)
    if (data.locations[id].name !== locationName) continue

    data.locations[id].owner = userName
    db.set(data)
    break
  }
  res.send('saved')
})

server.listen(63772, function () {
  console.log('%s listening at %s', server.name, server.url)
})
