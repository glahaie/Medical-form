require('coffee-script').register();
var express = require('express');
var http = require('http');
var path = require('path');
var routes = require('./routes/index.coffee');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(require('stylus').middleware(__dirname + '/public'));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/nouveau', routes.nouveau);
app.get('/suivis', routes.suivis);
app.post('/entrerDossier', routes.nouveauDossier);
app.post('/modifierDossier',routes.modifierDossier);
app.get('/:noDossier', routes.dossier);
app.get('/:noDossier/modifier', routes.modifier);
app.get('/', routes.index);

http.createServer(app).listen(app.get('port'), function () {
  console.log('Express server listening on port ' + app.get('port'));
});
