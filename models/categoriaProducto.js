const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class CategoriaProducto extends Model {}

  CategoriaProducto.init(
    {
      // Define fields
      idCategoriaProducto: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      nombre_categoria: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      fecha_creacion: {
        type: DataTypes.DATE, defaultValue: DataTypes.NOW, allowNull: false,

      },

      id_estado: { 
        type: DataTypes.INTEGER, references: { model: 'Estado', key: 'idEstado', }, allowNull: false,
    }
      
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'CategoriaProducto', // Name of the model
      tableName: 'CategoriaProducto', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return CategoriaProducto;
};
