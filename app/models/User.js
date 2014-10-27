// Generated by CoffeeScript 1.8.0

/*
 * User.coffee
 *
 * Modelo de la base de datos que almacenará los datos del usuario de la
 * aplicación.
 *
 * Usamos bcrypt para hashear los passwords. Lo usamos también para
 * verificar que los passwords que se introducen al inicio de sesión son
 * o no válidos.
 *
 */
var UserSchema, bcrypt, mongoose;

mongoose = require('mongoose');

bcrypt = require('bcrypt');

UserSchema = mongoose.Schema({
  'Nombre': {
    type: String,
    index: {
      unique: false,
      required: true
    }
  },
  'User': {
    type: String,
    index: {
      unique: true,
      required: true
    }
  },
  'Pass': {
    type: String,
    index: {
      required: true
    }
  },
  'Admin': {
    type: Boolean,
    "default": false
  }
});

UserSchema.statics.genHash = function(pass, callback) {
  return bcrypt.genSalt(10, function(err, salt) {
    if (err) {
      console.log(err);
      return callback("Error: Imposible guardar el password, por favor solicita ayuda técnica. Código 1.");
    } else {
      return bcrypt.hash(pass, salt, function(errHash, hash) {
        if (errHash) {
          console.log("Hubo un error al Hasehar: " + errHash);
          return callback("Error: Imposible guardar el password, por favor solicita ayuda técnica. Código 2.");
        } else {
          return callback(null, hash);
        }
      });
    }
  });
};

UserSchema.methods.isValidPass = function(pass, callback) {
  return bcrypt.compare(pass, this.Pass, function(err, res) {
    if (err) {
      console.log(err);
      return callback("Error: No es posible comunicar con la base de datos. Por favor solicita ayuda técnica. Código 3");
    } else {
      return callback(null, res);
    }
  });
};

UserSchema.methods.isAdmin = function() {
  return this.Admin;
};

UserSchema.methods.isActive = function() {
  return this.Active;
};

UserSchema.methods.Activate = function(callback) {
  this.Active = true;
  return this.save(function(err) {
    if (err) {
      console.log(err);
      return callback(true);
    } else {
      return callback(false);
    }
  });
};

module.exports = mongoose.model('User', UserSchema);
