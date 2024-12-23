const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Usuario extends Model {}

  Rol.init(
    {
      // Define fields
      idUsuario: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      correo_electronico: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      nombre_completo: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      contrasena_usuario: {
        type: DataTypes.STRING,
        allowNull: false,
      },
      fecha_nacimiento: {
        type: DataTypes.DATE,
        allowNull: false,
      },
      fecha_creacion: {
        type: DataTypes.DATE, defaultValue: DataTypes.NOW, allowNull: false,

      },
      id_rol: { 
        type: DataTypes.INTEGER, references: { model: 'Rol', key: 'idRol', }, allowNull: false,
    },
    id_estado: { 
        type: DataTypes.INTEGER, references: { model: 'Estado', key: 'idEstado', }, allowNull: false,
    },
    id_cliente: { 
        type: DataTypes.INTEGER, references: { model: 'Cliente', key: 'idCliente', }, allowNull: false,
    }
    },
    {
      sequelize, // Pass the Sequelize instance
      modelName: 'Usuario', // Name of the model
      tableName: 'Usuario', // Name of the table in the database
      timestamps: false, // Disable timestamps if not present in the table
    }
  );

  return Usuario;
};
