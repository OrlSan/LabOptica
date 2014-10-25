# app/routes.coffee -> app/routes.js

User = require './models/User'
Datos = require './models/Datos'

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
