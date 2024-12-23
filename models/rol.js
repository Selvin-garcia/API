const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Rol extends Model {}

  Rol.init(
    {
      // Define fields
      idRol: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      nombre_rol: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      id_estado: { 
        type: DataTypes.INTEGER, references: { model: 'Estado', key: 'idEstado', }, allowNull: false,
    },
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'Rol', // Name of the model
      tableName: 'Rol', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return Rol;
};
