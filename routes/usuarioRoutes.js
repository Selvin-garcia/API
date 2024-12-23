const express = require("express");
const usuarioController = require("../controllers/usuarioController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");


const router = express.Router();

// Definir rutas

router.post("/crear", verificarTokenController.verificarTokenAdminOperador,usuarioController.crearUsuarios);
router.get("/",verificarTokenController.verificarTokenAdminOperador, usuarioController.obtenerUsuarios);
router.put("/actualizar", verificarTokenController.verificarTokenAdminOperador,usuarioController.actualizarUsuarios);

module.exports = router;
