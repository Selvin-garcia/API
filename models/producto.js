const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Producto extends Model {}

  Producto.init(
    {
      // Define fields
      idProducto: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      nombre_producto: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      marca: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      codigo: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      stock: {
        type: DataTypes.FLOAT,
        allowNull: false,
      },
     
      precio: {
        type: DataTypes.DECIMAL,
        allowNull: false,
      },
     
      

      fecha_creacion: {
        type: DataTypes.DATE, defaultValue: DataTypes.NOW, allowNull: false,

      },

      foto: {
        type: DataTypes.BLOB('long'),
        allowNull: false,
      },
      id_categoria_producto: { 
        type: DataTypes.INTEGER, references: { model: 'CategoriaProducto', key: 'idCategoriaProducto', }, allowNull: false,
    },
      
      id_estado: { 
        type: DataTypes.INTEGER, references: { model: 'Estado', key: 'idEstado', }, allowNull: false,
    }
      
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'Producto', // Name of the model
      tableName: 'Producto', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return Producto;
};
