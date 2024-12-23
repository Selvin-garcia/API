const express = require("express");
const autorizacionController = require("../controllers/autorizacionController.js");

const router = express.Router();

// Definir rutas

router.post("/registro", autorizacionController.registrarUsuario);
router.post("/login", autorizacionController.loginUsuario);


module.exports = router;
