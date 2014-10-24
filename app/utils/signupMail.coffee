###
# Enviar un correo electrónico a quien se registre en el
# sistema y así poder verificar la identidad y la
# propiedad de la dirección de correo electrónico del
# usuario.
###

mailer = require 'nodemailer'
smtpTransp = require 'nodemailer-smtp-transport'

# El transporte contiene todos los datos de la sesión
# para lograr una conexión a SMTP con la dirección
# de correo electrónico indicada.
transport = mailer.createTransport smtpTransp({
    host: 'mail.celex.com'
    port: 25
    auth: {
        user: 'LabOpticasatelLabOpticae@celex.com'
        pass: 'Celex2013*'
    }
})

template = '<h2>¡Bienvenido a LabOptica!</h2>
Hola, Por favor verifica tu cuenta de correo electrónico
dando click en <a href="localhost:8080/confirm/[[ID]]">este enlace</a>, o bien
copiando y pegando directamente el siguiente link en tu navegador: <br>
http://localhost:8080/confirm/[[ID]] <br>
<br>
Agradecemos tu preferencia, <br> <i>El equipo de LabOptica</i>'

module.exports = (destino, id, callback) ->
    # Llenamos las opciones y todos los datos del correo
    # electrónico para confirmar la cuenta y activarla
    mailOptions = {
        from: 'LabOptica <LabOpticasatelLabOpticae@celex.com>'
        to: destino
        subject: 'Bienvenido a LabOptica'
        text: 'Hola! Por favor verifica tu cuenta de correo electrónico en http://localhost:8080/confirm/' + id
        html: template.replace('[[ID]]', id)
    }

    # Enviarmos el correo electrónico llenado arriba usando
    # el transporte ya definido
    transport.sendMail mailOptions, (err, info) ->
        if err
            console.log err
            return callback("No fue posible enviar el correo electrónico. Error interno del sistema.")
        else
            console.log info
            if info.accepted[0] is destino
                return callback(null)
            else
                return callback("La dirección de correo electrónico proporcionada no es válida.")
