const router = require("express").Router(),
 rolRoutes = require("./rolRoutes.js"),
 clienteRoutes = require("./clienteRoutes.js"),
 usuarioRoutes = require("./usuarioRoutes.js"),
 categoriaProductoRoutes = require("./categoriaProductoRoutes.js"),
 productoRoutes = require("./productoRoutes.js"),
 ordenRoutes = require("./ordenRoutes.js"),
 autorizacionRoutes = require("./autorizacionRoutes.js"),
 errorRoutes = require("./errorRoutes.js");

router.use("/roles", rolRoutes);
router.use("/clientes", clienteRoutes);
router.use("/usuarios", usuarioRoutes);
router.use("/autorizacion", autorizacionRoutes);
router.use("/categoriaProductos", categoriaProductoRoutes);
router.use("/productos", productoRoutes);
router.use("/ordenes", ordenRoutes);

//error debe ir siempre delante de las rutas
router.use("/", errorRoutes);
module.exports = router;