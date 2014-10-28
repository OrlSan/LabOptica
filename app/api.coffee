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
#
# Con los datos que no estén vigentes no haremos nada por el momento,
# pero queda a reserva revisarlos para ver cuáles han sido borrados.
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
                            model: muestra
                        }
    else
        res.json {
            success: false
            message: "Debes introducir un número válido para la muestra."
        }

router.put '/:id', (req, res) ->
    console.log req.params.id
    # No es necesario buscar un registro vigente, pues los que no estén vigentes
    # no pueden ser obtenidos vía la API en la ruta /datos.json.
    Datos.findOne { _id: id }, (err, doc) ->
        res.json {
            success: true
            message: "Completada la operación"
        }


router.delete '/:id', (req, res) ->
    console.log "Anulando el registro con el ID #{req.params.id}"
    Datos.findOne { _id: req.params.id }, (err, registro) ->
        if err
            console.log "Ocurrió un error al bucar el registro #{req.params.id}: #{err}"
            res.json {
                success: false
                message: 'Error interno, reintenta por favor.'
            }
        # Si la búsqueda en la base de datos da un resultado, lo modificamos.
        if registro
            # Cambiamos el estatus del registro para anularlo.
            registro.Vigente = false
            # Guardamos el registro en la base de datos con los cambios.
            registro.save (saveErr) ->
                if saveErr
                    res.json {
                        success: false
                        message: "No se puede guardar el cambio en la base de datos, por favor pide ayuda."
                    }
                else
                    res.json {
                        success: true
                        message: "El registro se anuló satisfactoriamente."
                    }
        # Si no se encuentra un registro con ese ID
        else
            res.json {
                success: false
                message: "No podemos encontrar el registro que quieres anular, por favor pide ayuda."
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
