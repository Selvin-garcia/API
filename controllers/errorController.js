

const httpStatus = require("http-status-codes");
exports.respondNoResourceFound = (req, res) => {
 let errorCode = httpStatus.NOT_FOUND;
 res.status(errorCode);
 res.send(`${errorCode} | La página que buscas no existe!`);
};
exports.respondInternalError = (error, req, res, next) => {
 let errorCode = httpStatus.INTERNAL_SERVER_ERROR;
 console.log(`ocurrio un ERROR: ${error.stack}`)
 res.status(errorCode);
 res.send(`${errorCode} | Lo sentimos, tuvimos problemas para
    procesar esta información!`);
};