###
#  apiRouter
#
# Router de Express.js que recibe y procesa todas las peticiones
# hechas desde Backbone hacia la aplicación en la ruta montada,
# actualmente '/datos.json'
#
# El Router crea, actualiza, borra y manda toda la información a
# la aplicación Backbone en el frontend para interactuar con el
# usuario.
###

# Cargamos Express y generamos una instancia del Router.
express = require 'express'
router = express.Router()

# Cargamos el modelo de la base de datos para hacer consultas
# y transacciones sobre los datos almacenados
Datos = require './models/Datos'

router.get '/', (req, res) ->
    # Regresamos aquellos registros vigentes, es decir, aquellos
    # que no hayan sido descartados por algún usuario.
    Datos.find { Vigente: true }
    .sort { Number: -1 }
    .exec (err, documents) ->
        if err
            res.json {
                success: false
                message: 'Hubo un error con la base de datos. Pide ayuda.'
            }
        else
                    res.json documents

router.post '/', (req, res) ->
    # Si falta en número de registro, el usuario introduce una cadena de texto,
    # o si el número de registro no es un número positivo, regresamos un error.
    if parseInt(req.body.Number) > 0 and (req.body.Number isnt null)
        # Buscamos un registro con un número de muestra igual y que esté
        # Vigente, si lo está, regresamos un error.
        Datos.findOne { Number: req.body.Number, Vigente: true }, (err, doc) ->
            if err
                console.log "Hubo un error con la base de datos: #{err}"
                res.json {
                    success: false
                    message: "Hubo un error con la base de datos: #{err}"
                }
            if doc
                console.log "Ya se encuentra un registro de esta muestra"
                res.json {
                    success: false
                    message: "Ya se encuentra un registro de esta muestra"
                }
            else
                muestra = new Datos {
                    Number: req.body.Number
                    Gender: req.body.Gender
                    Color: req.body.Color
                    Tinte: req.body.Tinte
                }

                muestra.save (saveErr) ->
                    if saveErr
                        console.log "Hubo un error al guardar la información: #{saveErr}"
                        res.json {
                            success: false
                            message: "No se puede guardar la información. Pide ayuda."
                        }
                    else
                        res.json {
                            success: true
                            message: "La información se guardó correctamente"
                        }
    else
        res.json {
            success: false
            message: "Debes introducir un número válido para la muestra."
        }


# Middleware para verificar si el usuario está autenticado y, de
# no ser así, mandar un mensaje de error
router.use (req, res, next) ->
    if req.isAuthenticated()
        next()
    else
        res.json {
            success: false
            message: 'Debes iniciar sesión para continuar'
        }


# Exportamos el Router para ser usado en la aplicación que lo requiera
module.exports = router
