var restify = require('restify')

require('console-stamp')(console)

var server = restify.createServer({
  name: 'OccupyHdM-REST-backend',
  version: '0.0.0'
})
server.use(restify.acceptParser(server.acceptable))
server.use(restify.queryParser())
server.use(restify.bodyParser())

var goals = {'locations': [
  {'name': 'Location 1', 'lat': 48.742070, 'lon': 9.102263},
  {'name': 'Location 2', 'lat': 48.740995, 'lon': 9.101709}
]}

server.get('/goals', function (req, res, next) {
  console.log('received a request on /goals')
  res.send(goals)
  return next()
})

server.listen(8080, function () {
  console.log('%s listening at %s', server.name, server.url)
})
