// Generated by CoffeeScript 1.8.0

/*
 * App de ayuda para medir el ancho del cabello de la Facultad de Ciencias.
 */
var app, bodyParser, config, cookieParser, dbopts, express, logger, mongoStore, mongoose, passport, session, uuid;

express = require('express');

app = express();

mongoose = require('mongoose');

logger = require('morgan');

passport = require('passport');

bodyParser = require('body-parser');

cookieParser = require('cookie-parser');

session = require('express-session');

mongoStore = require('connect-mongo')(session);

uuid = require('node-uuid');

config = require('./config');

dbopts = {
  server: {
    socketOptions: {
      keepAlive: 1
    }
  },
  replset: {
    socketOptions: {
      keepAlive: 1
    }
  }
};

mongoose.connect(config.mongoURL, dbopts, function(err) {
  if (err) {
    return console.log('No se puede conectar a la base de datos');
  } else {
    return console.log('Conectado correctamente a la base de datos');
  }
});

require('./config/passport')(passport);

app.use('/js', express["static"](__dirname + '/scripts/js'));

app.use('/css', express["static"](__dirname + '/styles/css'));

app.use(express["static"](__dirname + '/public'));

app.use(logger('dev'));

app.use(bodyParser.json());

app.use(bodyParser.urlencoded({
  extended: true
}));

app.use(session({
  genid: function(req) {
    return uuid.v4();
  },
  name: 'FCiencias_Optica',
  secret: process.env.OPENSHIFT_SECRET_TOKEN || 'SECRET password for a secure cookie',
  saveUninitialized: true,
  resave: true,
  cookie: {
    maxAge: 3600000 * 24
  },
  store: new mongoStore({
    url: config.mongoURL,
    db: 'laboptica',
    stringify: false
  })
}));

app.use(passport.initialize());

app.use(passport.session());

app.locals.pretty = true;

require('./app/routes')(app, passport);

app.listen(config.port, config.address, function() {
  return console.log("Escuchando en la dirección " + config.address + ":" + config.port);
});
