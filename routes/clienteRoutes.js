const express = require("express");
const clienteController = require("../controllers/clienteController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");
const router = express.Router();

// Definir rutas

router.post("/crear", clienteController.crearClientes);
router.get("/", verificarTokenController.verificarTokenUsuarioFinal,clienteController.obtenerClientes);
router.put("/actualizar", verificarTokenController.verificarTokenUsuarioFinal,clienteController.actualizarClientes);

module.exports = router;
