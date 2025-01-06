const { sequelize, Orden } = require("../db.js");

exports.crearOrdenesConDetalle = async (req, res, next) => {
 // Obtener los datos JSON del cuerpo de la solicitud POST 
 const OrdenJson = JSON.stringify(req.body);
  try {
      
      // Validar entrada
      if (!OrdenJson) {
          return res.status(400).json({
              Status: 'No completado',
              Message: 'Los datos son necesarios',
              id_registro: null
          });
      }

      // Llamar al procedimiento almacenado para crear el rol y devolver el resultado
      const resultado = await sequelize.query(
          'EXEC CrearOrdenesConDetalle @OrdenJson = :OrdenJson',
          {
              replacements: { OrdenJson },
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
}




exports.obtenerOrdenes = async (req, res, next) => {
    // Obtener los datos JSON del cuerpo de la solicitud POST 
    const ids = req.body; 
    const DatosJson = ids.length ? JSON.stringify(ids) : '[]'; // Handle empty input
  
    try {
      // Validar entrada
      if (!DatosJson) {
        return res.status(400).json({
          Status: 'No completado',
          Message: 'Los datos son necesarios',
          id_registro: null,
        });
      }
  
      // Llamar al procedimiento almacenado para crear el rol y devolver el resultado
      const resultado = await sequelize.query(
        'EXEC ObtenerOrdenes @DatosJson = :DatosJson',
        {
          replacements: { DatosJson },
          type: sequelize.QueryTypes.SELECT,
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
  

  
  exports.actualizarOrdenes = async (req, res, next) => {
    const datosJson = req.body;
    
    if (!datosJson || Object.keys(datosJson).length === 0) {
      return res.status(400).json({
        Estado: 'No completado',
        Mensaje: 'Los datos son necesarios'
      });
    }
  
    const DatosJsonString = JSON.stringify(datosJson);
  
    try {
      const resultado = await sequelize.query(
        'EXEC ActualizarOrdenes @DatosJson = :DatosJson',
        {
          replacements: { DatosJson: DatosJsonString },
          type: sequelize.QueryTypes.RAW
        }
      );
  
      if (resultado[0].Estado === 'No completado') {
        return res.status(500).json(resultado[0]);
      }
  
      return res.status(200).json(resultado[0]);
  
    } catch (error) {
      console.error('Error en el servidor:', error);
      error.status = 500;
      return next(error);
    }
  };
   