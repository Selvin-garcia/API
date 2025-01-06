const express = require("express");
const ordenController = require("../controllers/ordenController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");

const router = express.Router();

// Definir rutas

router.post("/crear",ordenController.crearOrdenesConDetalle);
router.get("/", ordenController.obtenerOrdenes);
router.put("/actualizar", ordenController.actualizarOrdenes);

module.exports = router;
