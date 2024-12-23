const express = require("express");
const clienteController = require("../controllers/clienteController.js");

const router = express.Router();

// Definir rutas

router.post("/crear", clienteController.crearClientes);
router.get("/", clienteController.obtenerClientes);
router.put("/actualizar", clienteController.actualizarClientes);

module.exports = router;
