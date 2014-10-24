###
#  Datos.coffee - Datos.js
#
# Modelo de la base de datos para guardar los patrones de
# datos necesarios para guardar la información de las medidas
# obtenidas en el laboratorio.
#
###

mongoose = require 'mongoose'

DatosSchema = mongoose.Schema
    Number:
        type: Number
        index:
            required: true
    Gender:
        type: String
        index:
            required: true
    Color:
        type: String
        index:
            required: true
    Tinte:
        type: Boolean
        index:
            required: true
    Vigente:
        type: Boolean
        default: true

module.exports = mongoose.model 'Datos', DatosSchema
