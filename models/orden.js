const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const Orden = sequelize.define('Orden', {
    idOrden: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    direccion_envio: {
        type: DataTypes.STRING,
        allowNull: false
    },
    telefono: {
        type: DataTypes.STRING,
        allowNull: false
    },
    correo_electronico: {
        type: DataTypes.STRING,
        allowNull: false
    },
    fecha_envio: {
        type: DataTypes.DATE,
        allowNull: false
    },
   
    id_usuario: { 
        type: DataTypes.INTEGER, references: { model: 'Usuario', key: 'idUsuario', }, allowNull: false,
    },
      
      id_estado: { 
        type: DataTypes.INTEGER, references: { model: 'Estado', key: 'idEstado', }, allowNull: false,
    }
}, {
    tableName: 'Orden',
    timestamps: false
});

module.exports = Orden;
