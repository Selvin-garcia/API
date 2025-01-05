const express = require("express");
const autorizacionController = require("../controllers/autorizacionController.js");
const path = require('path');
const router = express.Router();

// Definir rutas

router.post("/registro", autorizacionController.registrarUsuario);
router.post("/login", autorizacionController.loginUsuario);

// Sirve las imagenes 
router.use('/imagenes', express.static(path.join(__dirname, '../uploads/frontend/login')));

module.exports = router;
