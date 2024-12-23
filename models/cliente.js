const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Cliente extends Model {}

  Rol.init(
    {
      // Define fields
      idCliente: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      razon_social: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      nombre_comercial: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      direccion_envio: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      telefono: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      correo_electronico: {
        type: DataTypes.STRING,
        allowNull: false,
      }
      
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'Cliente', // Name of the model
      tableName: 'Cliente', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return Cliente;
};
