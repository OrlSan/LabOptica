###
# passport.coffee
#
# Aquí se definen las políticas de Passport a usar para autenticar y registrar
# a los usuarios de la aplicación.
# Se usa solamente una estrategia local, no se usará facebook ni ningún otro
# método de autenticación de usuarios.
###

LocalStrategy = require('passport-local').Strategy

User = require '../app/models/User'
signupMail = require '../app/utils/signupMail'

module.exports = (passport) ->
    # Configuración del inicio de sesión en Passport
    passport.serializeUser (user, callback) ->
        callback(null, user.id)

    # Cerrar la sesión
    passport.deserializeUser (id, callback) ->
        User.findById id, (err, user) ->
            callback(err, user)


    # Alta de usuarios
    passport.use 'local-signup', new LocalStrategy {
        usernameField : 'email'
        passwordField : 'password'
        passReqToCallback : true
    }, (req, email, password, callback) ->
        process.nextTick () ->
            User.findOne { 'Correo': email }, (err, user) ->
                return callback(err) if err
                if user
                    return callback(null, false,
                    'El usuario ya se encuentra actualmente registrado')
                else
                    # Enviar un correo electrónico de confirmación de
                    # alta de usuarios.
                    signupMail email, 'lol', (c_err) ->
                        if c_err
                            console.log c_err
                        else
                            console.log "Correo enviado correctamente"
                            newUser = new User()
                            # Generamos el Hash del password del usuario
                            User.genHash password, (p_err, hash) ->
                                if p_err
                                    console.log p_err
                                    return callback(p_err, null)

                                newUser.Correo = email
                                newUser.Pass   = hash

                                newUser.save (s_err) ->
                                    if s_err
                                        throw err
                                     return callback(null, newUser)

    # Autenticación de usuarios
    passport.use 'local-login', new LocalStrategy {
        usernameField : 'user'
        passwordField : 'pass'
        passReqToCallback : true
    }, (req, name, password, callback) ->
        console.log "Recibida petición de inicio de sesión"
        # Buscamos el usuario cuyo correo nos fue proporcionado
        User.findOne { 'User': name }, (err, user) ->
            if err
                return callback(err)
            if not user
                console.log 'No hay un usuario que coincida'
                return callback(null, false, "No se encuentra el usuario registrado")
            else
                # Verificamos si el password proporcionado coincide con el Hash
                # guardado en la base de datos.
                console.log user
                user.isValidPass password, (err, valid) ->
                    if valid
                        console.log 'Password aceptado'
                        return callback(null, user)
                    else
                        console.log 'El password no es válido'
                        return callback(null, false, "El password no es válido")
