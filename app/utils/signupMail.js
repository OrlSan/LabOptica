// Generated by CoffeeScript 1.8.0

/*
 * Enviar un correo electrónico a quien se registre en el
 * sistema y así poder verificar la identidad y la
 * propiedad de la dirección de correo electrónico del
 * usuario.
 */
var mailer, smtpTransp, template, transport;

mailer = require('nodemailer');

smtpTransp = require('nodemailer-smtp-transport');

transport = mailer.createTransport(smtpTransp({
  host: 'mail.celex.com',
  port: 25,
  auth: {
    user: 'LabOpticasatelLabOpticae@celex.com',
    pass: 'Celex2013*'
  }
}));

template = '<h2>¡Bienvenido a LabOptica!</h2> Hola, Por favor verifica tu cuenta de correo electrónico dando click en <a href="localhost:8080/confirm/[[ID]]">este enlace</a>, o bien copiando y pegando directamente el siguiente link en tu navegador: <br> http://localhost:8080/confirm/[[ID]] <br> <br> Agradecemos tu preferencia, <br> <i>El equipo de LabOptica</i>';

module.exports = function(destino, id, callback) {
  var mailOptions;
  mailOptions = {
    from: 'LabOptica <LabOpticasatelLabOpticae@celex.com>',
    to: destino,
    subject: 'Bienvenido a LabOptica',
    text: 'Hola! Por favor verifica tu cuenta de correo electrónico en http://localhost:8080/confirm/' + id,
    html: template.replace('[[ID]]', id)
  };
  return transport.sendMail(mailOptions, function(err, info) {
    if (err) {
      console.log(err);
      return callback("No fue posible enviar el correo electrónico. Error interno del sistema.");
    } else {
      console.log(info);
      if (info.accepted[0] === destino) {
        return callback(null);
      } else {
        return callback("La dirección de correo electrónico proporcionada no es válida.");
      }
    }
  });
};