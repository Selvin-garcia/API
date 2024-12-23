const express = require("express");
const productoController = require("../controllers/ProductoController.js");

const router = express.Router();

// Definir rutas

router.post("/crear", productoController.crearProductos);
router.get("/", productoController.obtenerProductos);
router.put("/actualizar", productoController.actualizarProductos);

module.exports = router;
