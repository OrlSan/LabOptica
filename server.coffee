###
# App de ayuda para medir el ancho del cabello de la Facultad de Ciencias.
###

# Cargamos los módulos necesarios ====================================
express      = require 'express'
app          = express()
mongoose     = require 'mongoose'
logger       = require 'morgan'
passport     = require 'passport'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
session      = require 'express-session'
mongoStore   = require('connect-mongo')(session);
uuid         = require 'node-uuid'

# Cargamos las configuraciones =======================================
config = require './config'

# Base de datos
dbopts =
    server:
        socketOptions:
            keepAlive: 1
    replset:
        socketOptions:
            keepAlive: 1

# Base de datos
mongoose.connect config.mongoURL, dbopts, (err) ->
    if err
        console.log 'No se puede conectar a la base de datos'
    else
        console.log 'Conectado correctamente a la base de datos'

# Cargar las configuraciones de Passport
require('./config/passport')(passport)

# Configuraciones de Express
app.use '/js', express.static(__dirname + '/scripts/js')
app.use '/css', express.static(__dirname + '/styles/css')
app.use express.static(__dirname + '/public')
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: true })

# Configuración para las sesiones
app.use session {
    genid: (req) ->
        # Generamos UUID's únicos por sesión
        return uuid.v4()
    # El nombre de la cookie y el secreto
    name: 'FCiencias_Optica'
    secret: 'SECRET password for a secure cookie'
    saveUninitialized: true
    resave: true
    cookie:
        # Un día como máximo para vigencia de una sesión (esto puede
        # cambiar a futuro, en producción)
        maxAge: 3600000*24
    store: new mongoStore({
        # Usar la misma base de datos que las facturas y los usuarios
        url: config.mongoURL
        db: 'laboptica'
        # Guardar los datos como JSON en lugar de texto plano en Mongo
        stringify: false
    })
}

app.use passport.initialize()
app.use passport.session()

# Para renderizar HTML legible
app.locals.pretty = true

# Rutas ==============================================================
require('./app/routes')(app, passport)

# Iniciar la aplicación ==============================================
app.listen config.port, config.address, () ->
    console.log "Escuchando en la dirección #{config.address}:#{config.port}"
