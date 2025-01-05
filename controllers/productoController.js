const { sequelize } = require("../db.js");
const path = require('path');
const multer = require('multer');
const fs = require('fs');


// Configure Multer storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, path.join(__dirname, '../uploads/imagenes')); // Folder de destino para la carga de imagenes
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname)); // Usar fecha de carga
    }
});

const upload = multer({ storage: storage });

// Middleware para manejar la carga de imagenes
exports.CargarImagen = upload.single('imagen');

exports.crearProductos = async (req, res, next) => {
    try {
        // Obtener los datos JSON del cuerpo de la solicitud POST
        let DatosProductos = JSON.parse(req.body.producto);
        
        if (!DatosProductos) {
            return res.status(400).json({
                Status: 'No completado',
                Message: 'Los datos son necesarios',
                id_registro: null
            });
        }

        // Guardar la ruta de imagen cargada
        let imagenUrl = null;
        if (req.file) {
            imagenUrl =  req.file.filename; // ruta relativa imagen guardada

            // Assuming all products have the same image or this image is related to one specific product 
            DatosProductos = DatosProductos.map(product => {
                return { ...product, foto: imagenUrl };
            });
        }
        
        const DatosJson = JSON.stringify(DatosProductos); // Convert the updated products array to JSON string

        // Llamar al procedimiento almacenado para crear el producto y devolver el resultado
        const resultado = await sequelize.query(
            'EXEC CrearProductos @DatosJson = :DatosJson',
            {
                replacements: { DatosJson },
                type: sequelize.QueryTypes.RAW
            }
        );

        // Si el resultado contiene 'No completado', indicar fallo
        if (resultado[0].Estado === 'No completado') {
            return res.status(500).json(resultado[0]); // Devolver fallo con estado 500
        }

        // Si el resultado es exitoso, devolver éxito con estado 200
        return res.status(200).json(resultado[0]);  // El resultado ya contiene Status, Message, id_registro

    } catch (error) {
        console.error('Error en el servidor:', error);
        error.status = 500;
        return next(error); // Pasar el error al siguiente middleware
    }
};

exports.obtenerProductos = async (req, res, next) => {
    const DatosJson = JSON.stringify(req.body);
    try {
        // Llamar al procedimiento almacenado para obtener los productos y devolver el resultado
        const resultado = await sequelize.query(
            'EXEC ObtenerProductos @DatosJson = :DatosJson',
            {
                replacements: { DatosJson },
                type: sequelize.QueryTypes.SELECT
            }
        );

        // Si el resultado contiene 'No completado', indicar fallo
        if (resultado[0].Estado === 'No completado') {
            return res.status(500).json(resultado[0]); // Devolver fallo con estado 500
        }

        // Si el resultado es exitoso, devolver éxito con estado 200
        return res.status(200).json(resultado[0]);  // El resultado ya contiene Status, Message, id_registro

    } catch (error) {
        console.error('Error en el servidor:', error);
        error.status = 500;
        return next(error); // Pasar el error al siguiente middleware
    }
};

exports.actualizarProductos = async (req, res, next) => {
    const DatosJson = JSON.stringify(req.body);
    try {
        // Validar entrada
        if (!DatosJson) {
            return res.status(400).json({
                Status: 'No completado',
                Message: 'Los datos son necesarios',
                id_registro: null
            });
        }

        // Llamar al procedimiento almacenado para actualizar el producto y devolver el resultado
        const resultado = await sequelize.query(
            'EXEC ActualizarProductos @DatosJson = :DatosJson',
            {
                replacements: { DatosJson },
                type: sequelize.QueryTypes.RAW
            }
        );

        // Si el resultado contiene 'No completado', indicar fallo
        if (resultado[0].Estado === 'No completado') {
            return res.status(500).json(resultado[0]); // Devolver fallo con estado 500
        }

        // Si el resultado es exitoso, devolver éxito con estado 200
        return res.status(200).json(resultado[0]);  // El resultado ya contiene Status, Message, id_registro

    } catch (error) {
        console.error('Error en el servidor:', error);
        error.status = 500;
        return next(error); // Pasar el error al siguiente middleware
    }
};
