const express = require("express");
const categoriaProductoController = require("../controllers/categoriaProductoController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");

const router = express.Router();

// Definir rutas

router.post("/crear", verificarTokenController.verificarTokenAdminOperador,categoriaProductoController.crearCategoriaProductos);
router.get("/", verificarTokenController.verificarTokenAdminOperador,categoriaProductoController.obtenerCategoriaProductos);
router.put("/actualizar", verificarTokenController.verificarTokenAdminOperador,categoriaProductoController.actualizarCategoriaProductos);

module.exports = router;
