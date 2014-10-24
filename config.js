// Configuraciones de la aplicación

var config = {
    address: process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1',
    port: process.env.OPENSHIFT_NODEJS_PORT || 8080,
    mongoURL: process.env.OPENSHIFT_MONGODB_DB_URL || 'mongodb://localhost:27017/laboptica'
};

module.exports = config;
