const { sequelize, Usuario } = require("../db.js");
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

exports.registrarUsuario = async (req, res, next) => {
    const usuarios = req.body;

    console.log("Datos recibidos:", usuarios);
    console.log("JWT_SEC:", process.env.JWT_SEC);

    try {
        if (!usuarios || !Array.isArray(usuarios) || usuarios.length === 0) {
            return res.status(400).json({
                Estado: 'No completado',
                Mensaje: 'Los datos son necesarios',
                id_registro: null
            });
        }

        const usuariosEncriptados = await Promise.all(usuarios.map(async usuario => {
            const sal = await bcrypt.genSalt(10);
            usuario.contrasena_usuario = await bcrypt.hash(usuario.contrasena_usuario, sal);
            return usuario;
        }));

        const usuariosCompletos = usuariosEncriptados.map(usuario => ({
            correo_electronico: usuario.correo_electronico || "",
            nombre_completo: usuario.nombre_completo || "",
            contrasena_usuario: usuario.contrasena_usuario || "",
            telefono: usuario.telefono || "",
            fecha_nacimiento: usuario.fecha_nacimiento || "1900-01-01",
            id_rol: usuario.id_rol || 1,
            id_estado: usuario.id_estado || 1
        }));

        const DatosJson = JSON.stringify(usuariosCompletos);

        const resultado = await sequelize.query(
            'EXEC CrearUsuarios @DatosJson = :DatosJson',
            {
                replacements: { DatosJson },
                type: sequelize.QueryTypes.SELECT
            }
        );

        console.log("Resultado del procedimiento almacenado:", resultado);

        const resultadoJson = JSON.parse(resultado[0]['JSON_F52E2B61-18A1-11d1-B105-00805F49916B']);
        const usuario = resultadoJson.Datos[0];
        console.log("Usuario creado:", usuario);

        if (!process.env.JWT_SEC) {
            console.error('La clave JWT_SEC no está definida.');
            return res.status(500).json({
                Estado: 'No completado',
                Mensaje: 'Error en la configuración del servidor',
                id_registro: null
            });
        }

        const tokenAcceso = jwt.sign(
            {
                id: usuario.idUsuario,
            },
            process.env.JWT_SEC,
            { expiresIn: "1d" }
        );

        return res.status(200).json({ ...usuario, token: tokenAcceso });

    } catch (error) {
        console.error('Error en el servidor:', error);
        error.status = 500;
        return next(error);
    }
};





exports.loginUsuario = async (req, res, next) => {
    const usuarios = req.body;

    // Registro de depuración
    console.log("Datos recibidos:", usuarios);
    console.log("JWT_SEC:", process.env.JWT_SEC);

    try {
        // Validar entrada
        if (!usuarios || !Array.isArray(usuarios) || usuarios.length === 0) {
            return res.status(400).json({
                Estado: 'No completado',
                Mensaje: 'Los datos son necesarios',
                id_registro: null
            });
        }

        // Extraer el nombre del primer usuario en el array
        const { nombre_completo, contrasena_usuario } = usuarios[0];

        // Buscar el usuario por nombre de usuario
        const usuario = await sequelize.query(
            'SELECT idUsuario, contrasena_usuario FROM Usuario WHERE nombre_completo = :nombre_completo',
            {
                replacements: { nombre_completo },
                type: sequelize.QueryTypes.SELECT
            }
        );

        // Verificar que el usuario exista
        if (!usuario || usuario.length === 0) {
            return res.status(401).json("Usuario Incorrecto!");
        }

        // Obtener el ID y la contraseña encriptada del usuario
        const { idUsuario, contrasena_usuario: contrasenaEncriptada } = usuario[0];

        // Verificar la contraseña
        const contrasenaValida = await bcrypt.compare(contrasena_usuario, contrasenaEncriptada);
        if (!contrasenaValida) {
            return res.status(401).json("Contraseña Incorrecta!");
        }

        // Crear el array JSON con el ID del usuario
        const DatosJson = JSON.stringify([idUsuario]);

        // Obtener los datos completos del usuario usando el procedimiento almacenado
        const resultado = await sequelize.query(
            'EXEC ObtenerUsuarios @DatosJson = :DatosJson',
            {
                replacements: { DatosJson },
                type: sequelize.QueryTypes.SELECT
            }
        );

        // Registro de depuración
        console.log("Resultado del procedimiento almacenado:", resultado);

        // Analizar la respuesta JSON del procedimiento almacenado
        const resultadoJson = JSON.parse(resultado[0]['JSON_F52E2B61-18A1-11d1-B105-00805F49916B']);
        const usuarioCompleto = resultadoJson.Datos[0];

        // Registro de depuración
        console.log("Usuario autenticado:", usuarioCompleto);

        if (!process.env.JWT_SEC) {
            console.error('La clave JWT_SEC no está definida.');
            return res.status(500).json({
                Estado: 'No completado',
                Mensaje: 'Error en la configuración del servidor',
                id_registro: null
            });
        }

        // Crear token JWT
        const tokenAcceso = jwt.sign(
            {
                id: usuarioCompleto.idUsuario,
            },
            process.env.JWT_SEC,
            { expiresIn: "1d" }
        );

        // Devolver éxito con el token
        const { contrasena_usuario: pwd, ...otrosDatos } = usuarioCompleto;
        return res.status(200).json({ ...otrosDatos, token: tokenAcceso });

    } catch (error) {
        console.error('Error en el servidor:', error);
        error.status = 500;
        return next(error);
    }
};
