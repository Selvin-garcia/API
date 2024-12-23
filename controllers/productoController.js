const { sequelize, Producto } = require("../db.js");

exports.crearProductos = async (req, res, next) => {
 // Obtener los datos JSON del cuerpo de la solicitud POST 
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

      // Llamar al procedimiento almacenado para crear el rol y devolver el resultado
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
}



exports.obtenerProductos = async (req, res, next) => {
 // Obtener los datos JSON del cuerpo de la solicitud POST 
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

      // Llamar al procedimiento almacenado para crear el rol y devolver el resultado
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
  // Obtener los datos JSON del cuerpo de la solicitud POST 
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
 
       // Llamar al procedimiento almacenado para crear el rol y devolver el resultado
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
 }
 