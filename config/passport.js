// Generated by CoffeeScript 1.8.0

/*
 * passport.coffee
 *
 * Aquí se definen las políticas de Passport a usar para autenticar y registrar
 * a los usuarios de la aplicación.
 * Se usa solamente una estrategia local, no se usará facebook ni ningún otro
 * método de autenticación de usuarios.
 */
var LocalStrategy, User, signupMail;

LocalStrategy = require('passport-local').Strategy;

User = require('../app/models/User');

signupMail = require('../app/utils/signupMail');

module.exports = function(passport) {
  passport.serializeUser(function(user, callback) {
    return callback(null, user.id);
  });
  passport.deserializeUser(function(id, callback) {
    return User.findById(id, function(err, user) {
      return callback(err, user);
    });
  });
  passport.use('local-signup', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
  }, function(req, email, password, callback) {
    return process.nextTick(function() {
      return User.findOne({
        'Correo': email
      }, function(err, user) {
        if (err) {
          return callback(err);
        }
        if (user) {
          return callback(null, false, 'El usuario ya se encuentra actualmente registrado');
        } else {
          return signupMail(email, 'lol', function(c_err) {
            var newUser;
            if (c_err) {
              return console.log(c_err);
            } else {
              console.log("Correo enviado correctamente");
              newUser = new User();
              return User.genHash(password, function(p_err, hash) {
                if (p_err) {
                  console.log(p_err);
                  return callback(p_err, null);
                }
                newUser.Correo = email;
                newUser.Pass = hash;
                return newUser.save(function(s_err) {
                  if (s_err) {
                    throw err;
                  }
                  return callback(null, newUser);
                });
              });
            }
          });
        }
      });
    });
  }));
  return passport.use('local-login', new LocalStrategy({
    usernameField: 'email',
    passwordField: 'password',
    passReqToCallback: true
  }, function(req, email, password, callback) {
    return User.findOne({
      'Correo': email
    }, function(err, user) {
      if (err) {
        return callback(err);
      }
      if (!user) {
        console.log('No hay un usuario que coincida');
        return callback(null, false, "No se encuentra el usuario registrado");
      } else {
        return user.isValidPass(password, function(err, valid) {
          if (valid) {
            console.log('Password aceptado');
            return callback(null, user);
          } else {
            console.log('El password no es válido');
            return callback(null, false, "El password no es válido");
          }
        });
      }
    });
  }));
};
