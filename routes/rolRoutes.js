const express = require("express");
const rolController = require("../controllers/rolController.js");
const verificarTokenController = require("../controllers/verificarTokenController.js");
const router = express.Router();

// Definir rutas

router.post("/crear", verificarTokenController.verificarTokenAdmin,rolController.crearRoles);
router.get("/", rolController.obtenerRoles);
router.put("/actualizar", verificarTokenController.verificarTokenAdmin,rolController.actualizarRoles);

module.exports = router;
