const express = require("express");
const productoController = require("../controllers/ProductoController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");
const router = express.Router();

// Definir rutas

router.post("/crear",verificarTokenController.verificarTokenAdminOperador, productoController.crearProductos);
router.get("/", verificarTokenController.verificarTokenAdminOperador,productoController.obtenerProductos);
router.put("/actualizar", verificarTokenController.verificarTokenAdminOperador,productoController.actualizarProductos);

module.exports = router;
