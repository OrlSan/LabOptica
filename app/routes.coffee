###
# app/routes.coffee -> app/routes.js
#
# Rutas del servidor para la aplicación LabOptica, rutas
# que responden las peticiones web para interactuar con el
# frontend.
###

User = require './models/User'
Datos = require './models/Datos'
# Ruter para manejar las peticiones a la API
apiRouter = require './api'

module.exports = (app, passport) ->
    # Página de inicio
    app.get '/', (req, res) ->
        if req.isAuthenticated()
            res.redirect '/dashboard'
        else
            res.render 'index.jade'

    # La pantalla de administración de la cuenta
    app.get '/dashboard', isLoggedIn, (req, res) ->
        res.render 'dashboard.jade', req.user

    # Procesamiento del formulario de inicio de sesión.
    app.post '/login', passport.authenticate('local-login', {
        successRedirect : '/dashboard'
        failureRedirect : '/'
    })

    # La muestra, alta y edición de datos
    app.get '/datos', isLoggedIn, (req, res) ->
        res.render 'datos.jade', req.user


    # Usamos el Router de la aplicación para manejar todas las
    # peticiones a la ruta /datos.json
    app.use '/datos.json', apiRouter

    # Cambiar la contraseña
    app.get '/newPass', isLoggedIn, (req, res) ->
        res.render 'newPass.jade'

    app.post '/newPass', isLoggedIn, (req, res) ->
        console.log "recibida petición post"
        console.log req.body
        User.findOne { _id: req.user.id }, (err, user) ->
            if err
                res.json {
                    success: false
                    message: "Hubo un error con tu sesión, por favor repórtalo e inténtalo de nuevo"
                }
            if user
                user.isValidPass req.body.oldPass, (passErr, isValid) ->
                    if passErr
                        res.json {
                            success: false
                            message: "Hubo un error al procesar la contraseña. Pide ayuda e intenta de nuevo."
                        }
                    if isValid
                        User.genHash req.body.newPass, (genErr, newHash) ->
                            # Reemplazar el hash en la base de datos.
                            user.Pass = newHash
                            user.save (err) ->
                                if err
                                    console.log "Error al guardar: #{err}"
                                    res.json {
                                        success: false
                                        message: 'No se pudo completar la operación. Pide ayuda.'
                                    }
                                else
                                    res.json {
                                        success: true
                                        message: "El password fue actualizado correctamente."
                                    }
                    else
                        res.json {
                            success: false
                            message: "Parece que tu password no es válido, verifícalo."
                        }

    # Descarga de los datos como CSV
    app.get '/descarga.csv', (isLoggedIn), (req, res) ->
        console.log "Recibida petición de descarga"
        Datos.find { "Vigente": true }, (err, data) ->
            if err
                console.log "Hubo un error buscando"
                res.json { error: "No se pudo buscar en la base de datos" }
            else
                csv = "Numero, Genero, Color, Tinte, Medida, Incert\n"
                for item in data
                    csv += "#{item.Number}, #{item.Gender}, #{item.Color}, #{item.Tinte},#{item.Medida}, #{item.Incert}\n"

                res.set 'Content-Type', 'application/octet-stream'
                res.send csv


    # Cerrar sesión
    app.get '/logout', isLoggedIn, (req, res) ->
        req.logout()
        res.redirect '/'



# Esta función regresa el estatus de la sesión actual y, si el
# usuario no está autenticado lo redirige a la página de inicio.
isLoggedIn = (req, res, next) ->
    if req.isAuthenticated()
        return next()
    else
        res.redirect '/'

# Es lo mismo que la función anterior, pero esta regresa un JSON con un mensaje
# de falla de inicio de sesión en lugar de redirigir la petición a la pantalla
# de inicio de sesión. Es útil cuando las peticiones son en JSON desde jQuery
# o Backbone.
isSessioned = (req, res, next) ->
    if req.isAuthenticated()
        return next()
    else
        res.json { error: "Debes iniciar sesión para continuar." }
