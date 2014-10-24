###
# User.coffee
#
# Modelo de la base de datos que almacenará los datos del usuario de la
# aplicación.
#
# Usamos bcrypt para hashear los passwords. Lo usamos también para
# verificar que los passwords que se introducen al inicio de sesión son
# o no válidos.
#
###

mongoose = require 'mongoose'
bcrypt = require 'bcrypt'

UserSchema = mongoose.Schema
    'Nombre':
        type: String
        index:
            unique: false
            required: true
    'User':
        type: String
        index:
            unique: true
            required: true
    'Pass':
        type: String
        index:
            required: true
    'Admin':
        type: Boolean
        default: false


# Una función para generar un Hash usando Bcrypt de 10 saltos.
# La vamos a usar para guardar la contraseña.
UserSchema.statics.genHash = (pass, callback) ->
    bcrypt.genSalt 10, (err, salt) ->
        if err
            console.log err
            return callback("Error: Imposible guardar el password, por favor solicita ayuda técnica. Código 1.")
        else
            bcrypt.hash pass, salt, (err2, hash) ->
                if err2
                    console.log err2
                    return callback("Error: Imposible guardar el password, por favor solicita ayuda técnica. Código 2.")
                else
                    return callback(null, hash)

# Comparamos, para el inicio de sesión, si el Hash almacenado en
# la base de datos que corresponde al password ingresado en el
# formulario de ingreso al sistema.
UserSchema.methods.isValidPass = (pass, callback) ->
    bcrypt.compare pass, this.Pass, (err, res) ->
        if err
            console.log err
            return callback("Error: No es posible comunicar con la base de datos. Por favor solicita ayuda técnica. Código 3")
        else
            return callback(null, res)

UserSchema.methods.isAdmin = () ->
    return this.Admin

UserSchema.methods.isActive = () ->
    return this.Active

UserSchema.methods.Activate = (callback) ->
    this.Active = true
    this.save (err) ->
        if err
            console.log err
            return callback(true)
        else
            return callback(false)


module.exports = mongoose.model 'User', UserSchema
