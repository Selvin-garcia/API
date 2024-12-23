const express = require("express");
const categoriaProductoController = require("../controllers/categoriaProductoController.js");

const router = express.Router();

// Definir rutas

router.post("/crear", categoriaProductoController.crearCategoriaProductos);
router.get("/", categoriaProductoController.obtenerCategoriaProductos);
router.put("/actualizar", categoriaProductoController.actualizarCategoriaProductos);

module.exports = router;
