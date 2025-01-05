const express = require("express");
const productoController = require("../controllers/productoController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");
const path = require('path');
const router = express.Router();

// Definir rutas

router.post("/crear",productoController.CargarImagen , productoController.crearProductos);
router.get("/", productoController.obtenerProductos);
router.put("/actualizar", verificarTokenController.verificarTokenAdminOperador,productoController.actualizarProductos);


// Serve static files from the 'uploads' directory 
router.use('/imagenes', express.static(path.join(__dirname, '../uploads/backend/productos')));

module.exports = router;
