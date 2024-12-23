const express = require("express");
const rolController = require("../controllers/rolController.js");

const router = express.Router();

// Definir rutas

router.post("/crear", rolController.crearRoles);
router.get("/", rolController.obtenerRoles);
router.put("/actualizar", rolController.actualizarRoles);

module.exports = router;
