const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Estado extends Model {}

  Estado.init(
    {
      // Define fields
      idEstado: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      nombre_estado: {
        type: DataTypes.STRING,
        allowNull: false,
      }
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'Estado', // Name of the model
      tableName: 'Estado', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return Estado;
};
