const { sequelize } = require("../db.js");
const jwt = require('jsonwebtoken');

// Middleware para verificar token y rol
const verificarToken = (rolesPermitidos) => {
    return async (req, res, next) => {
        const token = req.headers['authorization'];

        // Registro de depuración
        console.log("Token recibido:", token);

        if (!token) {
            return res.status(403).json({ mensaje: 'Token requerido' });
        }

        try {
            const decoded = jwt.verify(token.replace("Bearer ", ""), process.env.JWT_SEC);

            // Registro de depuración
            console.log("Token decodificado:", decoded);

            req.user = decoded;

            // Obtener el rol del usuario desde la base de datos
            const usuario = await sequelize.query(
                'SELECT id_rol FROM Usuario WHERE idUsuario = :id',
                {
                    replacements: { id: req.user.id },
                    type: sequelize.QueryTypes.SELECT
                }
            );

            if (!usuario || usuario.length === 0) {
                return res.status(401).json({ mensaje: 'Usuario no encontrado' });
            }

            const { id_rol } = usuario[0];

            // Verificar si el rol del usuario está permitido
            if (!rolesPermitidos.includes(id_rol)) {
                return res.status(403).json({ mensaje: 'Acceso denegado' });
            }

            next();
        } catch (error) {
            console.error('Error al verificar el token:', error);
            return res.status(403).json({ mensaje: 'Token inválido', error });
        }
    };
};

exports.verificarTokenAdmin = verificarToken([1]);
exports.verificarTokenUsuarioFinal = verificarToken([2]);
exports.verificarTokenOperador = verificarToken([3]);
exports.verificarTokenAdminOperador = verificarToken([1, 3]);
