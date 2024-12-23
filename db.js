// db.js
const { Sequelize, DataTypes } = require("sequelize");

const sequelize = new Sequelize("GDA00140-OT-SelvinGomez", "SelvinGomez", "Javascript#25", {
  host: "localhost",
  dialect: "mssql",
  port: 1433,
  logging: false,
  dialectOptions: {
    encrypt: false,
  },
});

// Test database connection
sequelize.authenticate()
  .then(() => console.log("Database connected"))
  .catch((err) => console.error("Database connection failed:", err));

// Import models
const Rol = require("./models/rol.js")(sequelize, DataTypes);

// Export sequelize instance and models
module.exports = { sequelize, Rol };
