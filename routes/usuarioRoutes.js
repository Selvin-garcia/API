const express = require("express");
const usuarioController = require("../controllers/usuarioController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");
const autorizacionController = require("../controllers/autorizacionController.js")


const router = express.Router();

// Definir rutas

router.post("/crear",autorizacionController.registrarUsuario,usuarioController.crearUsuarios);
router.get("/", usuarioController.obtenerUsuarios);
router.put("/actualizar",usuarioController.actualizarUsuarios);

module.exports = router;
