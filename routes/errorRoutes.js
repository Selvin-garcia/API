const express = require("express");
const errorController = require("../controllers/errorController.js");

const router = express.Router();
// Error-handling middleware
router.use(errorController.respondNoResourceFound);
router.use(errorController.respondInternalError);

module.exports = router;