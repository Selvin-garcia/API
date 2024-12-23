

-- ========================================
-- 1.  Crear base de datos, nombre clave asignada + nombre apellido
-- ========================================


USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'GDA00140-OT-SelvinGomez')
BEGIN
    DROP DATABASE [GDA00140-OT-SelvinGomez];
END



GO
-- Declarar el nombre de la base de datos
DECLARE @nombre NVARCHAR(100);

SET @nombre = 'GDA00140-OT-SelvinGomez';


DECLARE @nombre_db NVARCHAR(100) = @nombre;



-- Crear la base de datos
EXEC('CREATE DATABASE [' + @nombre_db + ']');
GO

-- Cambair a la base de datos recien creada
USE [GDA00140-OT-SelvinGomez];
GO


-- ==================================================================================
--2. Creación de Tablas (Se adjunta sugerencia para realización de Tablas)
--3. Creación de Campos (Se adjunta sugerencia para realización de Tablas) 
--4. Creación de Relaciones (Se adjunta sugerencia para realización de las relaciones)
-- ===================================================================================

-- Borrar tablas si existen dentro de la base de datos.
DROP TABLE IF EXISTS dbo.Rol;
DROP TABLE IF EXISTS dbo.Estado;
DROP TABLE IF EXISTS dbo.Cliente;
DROP TABLE IF EXISTS dbo.Usuario;
DROP TABLE IF EXISTS dbo.CategoriaProducto;
DROP TABLE IF EXISTS dbo.Producto;
DROP TABLE IF EXISTS dbo.Orden;
DROP TABLE IF EXISTS dbo.OrdenDetalle;

-- 2 Tabla de Estado
CREATE TABLE Estado (
    idEstado INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado NVARCHAR(45) NOT NULL
);

-- 1 Tabla de Rol
CREATE TABLE Rol (
    idRol INT IDENTITY(1,1) PRIMARY KEY,
    nombre_rol NVARCHAR(45) NOT NULL,
	id_estado INT
	FOREIGN KEY (id_estado) REFERENCES Estado(idEstado)
);
-- 3 Tabla de Cliente
CREATE TABLE Cliente (
    idCliente INT IDENTITY(1,1) PRIMARY KEY,
    razon_social NVARCHAR(100) NOT NULL,
    nombre_comercial NVARCHAR(100),
    direccion_envio NVARCHAR(255),
    telefono NVARCHAR(45),
    correo_electronico NVARCHAR(100)
	
);

-- 4 Tabla de Usuario
CREATE TABLE Usuario (
    idUsuario INT IDENTITY(1,1) PRIMARY KEY,
    correo_electronico NVARCHAR(100) NOT NULL,
    nombre_completo NVARCHAR(100) NOT NULL,
    contrasena_usuario NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(45) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_rol INT,
    id_estado INT,
    id_cliente INT NULL, --No requerido, para permitir usuarios sin id_cliente
    FOREIGN KEY (id_rol) REFERENCES Rol(idRol),
    FOREIGN KEY (id_estado) REFERENCES Estado(idEstado),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(idCliente)
);




-- 5 Tabla de Categorías de Productos
CREATE TABLE CategoriaProducto (
    idCategoriaProducto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria NVARCHAR(45) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_estado INT,
    FOREIGN KEY (id_estado) REFERENCES Estado(idEstado)
);

-- 2.6 Tabla de Productos
CREATE TABLE Producto (
    idProducto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto NVARCHAR(100) NOT NULL,
    marca NVARCHAR(45),
    codigo NVARCHAR(45),
    stock FLOAT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    foto VARBINARY(MAX),
    id_categoria_producto INT NOT NULL,
	id_estado INT NOT NULL,
    FOREIGN KEY (id_categoria_producto) REFERENCES CategoriaProducto(idCategoriaProducto),
	FOREIGN KEY (id_estado) REFERENCES Estado(idEstado)
);

-- 2.7 Tabla de Órdenes
CREATE TABLE Orden (
    idOrden INT IDENTITY(1,1) PRIMARY KEY,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    direccion_envio NVARCHAR(255),
    telefono NVARCHAR(45),
    correo_electronico NVARCHAR(100),
    fecha_envio DATE,
    total_orden DECIMAL(10, 2),
    id_usuario INT,
    id_estado INT,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (id_estado) REFERENCES Estado(idEstado)
);

-- 2.8 Tabla de Detalles de Órdenes
CREATE TABLE OrdenDetalle (
    id_OrdenDetalle INT IDENTITY(1,1) PRIMARY KEY,
    cantidad INT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    subtotal AS (cantidad * precio) PERSISTED,
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    FOREIGN KEY (id_Orden) REFERENCES Orden(idOrden),
    FOREIGN KEY (id_Producto) REFERENCES Producto(idProducto)
);
GO



-- ========================================
-- 5. Creación de Procedimientos Almacenados (Deberás
-- insertar información y actualización de datos de todas 
-- las tablas de todos los campos).
-- (CRUD)
-- ========================================




--  ========
-- 2. TABLA ESTADO
--  ========

-- Create: Insertar un nuevo estado
CREATE PROCEDURE InsertarEstado 
    @nombre_estado NVARCHAR(45)
AS
BEGIN
    INSERT INTO Estado (nombre_estado)
    VALUES (@nombre_estado);
END
GO

-- Read: Obtener información de un estado por ID
CREATE PROCEDURE ObtenerEstado 
    @idEstado INT
AS
BEGIN
    SELECT * FROM Estado WHERE idEstado = @idEstado;
END
GO

-- Update: Actualizar información de un estado
CREATE PROCEDURE ActualizarEstado 
    @idEstado INT,
    @nombre_estado NVARCHAR(45)
AS
BEGIN
    UPDATE Estado
    SET nombre_estado = @nombre_estado
    WHERE idEstado = @idEstado;
END
GO

-- Delete: Eliminar un estado
CREATE PROCEDURE EliminarEstado 
    @idEstado INT
AS
BEGIN
    DELETE FROM Estado WHERE idEstado = @idEstado;
END
GO



--  ========
-- 1. TABLA ROL
--  ========
CREATE PROCEDURE CrearRoles
    @DatosJson NVARCHAR(MAX),
    @id_estado INT = 1  -- (1) estado Activo por defecto
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- declarar una tabla temporal para capturar los ids insertados
        DECLARE @IdsInsertados TABLE (idRol INT);

		--Insertar en la tabla Rol usando OPENJSON y capturar los Ids Insertados
        INSERT INTO Rol (nombre_rol, id_estado)
        OUTPUT inserted.idRol INTO @IdsInsertados
        SELECT 
            JSON_VALUE([value], '$.nombre_rol'),
            @id_estado
        FROM OPENJSON(@DatosJson);

        -- Retornar los datos insertados usando los ids Capturados

        SELECT
            'Completado' AS Estado,
            'Insertado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Rol
                WHERE idRol IN (SELECT idRol FROM @IdsInsertados)
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO


-- Read: Obtener información de múltiples roles por un array de IDs
CREATE PROCEDURE ObtenerRoles 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from Rol table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM Rol
                WHERE idRol IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO


CREATE PROCEDURE ActualizarRoles
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update Rol table using OPENJSON
        UPDATE Rol
        SET 
            nombre_rol = DatosJson.nombre_rol,
            id_estado = DatosJson.id_estado
        FROM OPENJSON(@DatosJson)
        WITH (
            idRol INT '$.idRol',
            nombre_rol NVARCHAR(100) '$.nombre_rol',
            id_estado INT '$.id_estado'
        ) AS DatosJson
        WHERE Rol.idRol = DatosJson.idRol;

        -- Fetch the updated data
        SELECT
            'Completado' AS Status,
            'Actualizado exitosamente' AS Message,
            (
                SELECT 
                    *
                FROM Rol
                WHERE idRol IN (SELECT idRol FROM OPENJSON(@DatosJson) WITH (idRol INT '$.idRol'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

--  ========
-- 3. TABLA CLIENTE
--  ========

CREATE PROCEDURE CrearClientes
    @DatosJson NVARCHAR(MAX)
    
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- declarar una tabla temporal para capturar los ids creados
        DECLARE @IdsCreados TABLE (idCliente INT);

		--Insertar en la tabla Rol usando OPENJSON y capturar los ids creados
        INSERT INTO Cliente(razon_social, nombre_comercial, direccion_envio,telefono,correo_electronico)
        OUTPUT inserted.idCliente INTO @IdsCreados
        SELECT 
            JSON_VALUE([value], '$.razon_social'),
			JSON_VALUE([value], '$.nombre_comercial'),
			JSON_VALUE([value], '$.direccion_envio'),
			JSON_VALUE([value], '$.telefono'),
			JSON_VALUE([value], '$.correo_electronico')
     
        FROM OPENJSON(@DatosJson);

        -- Retornar los datos insertados usando los ids Capturados

        SELECT
            'Completado' AS Estado,
            'Insertado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Cliente
                WHERE idCliente IN (SELECT idCliente FROM @IdsCreados)
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO




-- Read: Obtener información de múltiples roles por un array de IDs
CREATE PROCEDURE ObtenerClientes 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from Rol table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM Cliente
                WHERE idCliente IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO







CREATE PROCEDURE ActualizarClientes
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update Rol table using OPENJSON
        UPDATE Cliente
        SET 
		    --idCliente = DatosJson.idCliente,
            razon_social = DatosJson.razon_social,
            nombre_comercial = DatosJson.nombre_comercial,
			direccion_envio = DatosJson.direccion_envio,
			telefono = DatosJson.telefono,
			correo_electronico = DatosJson.correo_electronico
        FROM OPENJSON(@DatosJson)
        WITH (
            idCliente INT '$.idCliente',
            razon_social NVARCHAR(100) '$.razon_social',
			nombre_comercial NVARCHAR(100) '$.nombre_comercial',
			direccion_envio NVARCHAR(100) '$.direccion_envio',
			telefono NVARCHAR(100) '$.telefono',
			correo_electronico NVARCHAR(100) '$.correo_electronico'
         
        ) AS DatosJson
        WHERE Cliente.idCliente = DatosJson.idCliente;

        -- Fetch the updated data
        SELECT
            'Completado' AS Status,
            'Actualizado exitosamente' AS Message,
            (
                SELECT 
                    *
                FROM Cliente
                WHERE idCliente IN (SELECT idCliente FROM OPENJSON(@DatosJson) WITH (idCliente INT '$.idCliente'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



--  ========
-- 4. TABLA USUARIO
--  ========

-- Create: Insertar nuevos usuarios
CREATE PROCEDURE CrearUsuarios
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Declarar una tabla temporal para capturar los ids insertados
        DECLARE @IdsInsertados TABLE (idUsuario INT);

        -- Insertar en la tabla Usuario usando OPENJSON y capturar los ids insertados
        INSERT INTO Usuario (correo_electronico, nombre_completo, contrasena_usuario, telefono, fecha_nacimiento, id_rol, id_estado, id_cliente)
        OUTPUT inserted.idUsuario INTO @IdsInsertados
        SELECT 
            JSON_VALUE([value], '$.correo_electronico'),
            JSON_VALUE([value], '$.nombre_completo'),
            JSON_VALUE([value], '$.contrasena_usuario'),
            JSON_VALUE([value], '$.telefono'),
            JSON_VALUE([value], '$.fecha_nacimiento'),
            JSON_VALUE([value], '$.id_rol'),
            JSON_VALUE([value], '$.id_estado'),
            JSON_VALUE([value], '$.id_cliente')
        FROM OPENJSON(@DatosJson);

        -- Retornar los datos insertados usando los ids capturados
        SELECT
            'Completado' AS Estado,
            'Insertado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Usuario
                WHERE idUsuario IN (SELECT idUsuario FROM @IdsInsertados)
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



-- Read: Obtener información de múltiples usuarios por un array de IDs
CREATE PROCEDURE ObtenerUsuarios 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from Usuario table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM Usuario
                WHERE idUsuario IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



-- Update: Actualizar información de múltiples usuarios
CREATE PROCEDURE ActualizarUsuarios
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update Usuario table using OPENJSON
        UPDATE Usuario
        SET 
            correo_electronico = DatosJson.correo_electronico,
            nombre_completo = DatosJson.nombre_completo,
            contrasena_usuario = DatosJson.contrasena_usuario,
            telefono = DatosJson.telefono,
            fecha_nacimiento = DatosJson.fecha_nacimiento,
            id_rol = DatosJson.id_rol,
            id_estado = DatosJson.id_estado,
            id_cliente = DatosJson.id_cliente
        FROM OPENJSON(@DatosJson)
        WITH (
            idUsuario INT '$.idUsuario',
            correo_electronico NVARCHAR(100) '$.correo_electronico',
            nombre_completo NVARCHAR(100) '$.nombre_completo',
            contrasena_usuario NVARCHAR(100) '$.contrasena_usuario',
            telefono NVARCHAR(45) '$.telefono',
            fecha_nacimiento DATE '$.fecha_nacimiento',
            id_rol INT '$.id_rol',
            id_estado INT '$.id_estado',
            id_cliente INT '$.id_cliente'
        ) AS DatosJson
        WHERE Usuario.idUsuario = DatosJson.idUsuario;

        -- Fetch the updated data
        SELECT
            'Completado' AS Estado,
            'Actualizado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Usuario
                WHERE idUsuario IN (SELECT idUsuario FROM OPENJSON(@DatosJson) WITH (idUsuario INT '$.idUsuario'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



-- ========================================
-- 5. CategoriaProducto
-- ========================================
-- Create: Insertar nuevas categorías de productos
CREATE PROCEDURE CrearCategoriaProductos
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Declarar una tabla temporal para capturar los ids insertados
        DECLARE @IdsInsertados TABLE (idCategoriaProducto INT);

        -- Insertar en la tabla CategoriaProductos usando OPENJSON y capturar los ids insertados
        INSERT INTO CategoriaProducto (nombre_categoria, id_estado)
        OUTPUT inserted.idCategoriaProducto INTO @IdsInsertados
        SELECT 
            JSON_VALUE([value], '$.nombre_categoria'),
            JSON_VALUE([value], '$.id_estado')
        FROM OPENJSON(@DatosJson);

        -- Retornar los datos insertados usando los ids capturados
        SELECT
            'Completado' AS Estado,
            'Insertado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM CategoriaProducto
                WHERE idCategoriaProducto IN (SELECT idCategoriaProducto FROM @IdsInsertados)
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



-- Read: Obtener información de múltiples categorías de productos por un array de IDs
CREATE PROCEDURE ObtenerCategoriaProductos 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from CategoriaProductos table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM CategoriaProducto
                WHERE idCategoriaProducto IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO



-- Update: Actualizar información de múltiples categorías de productos
CREATE PROCEDURE ActualizarCategoriaProductos
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update CategoriaProductos table using OPENJSON
        UPDATE CategoriaProducto
        SET 
            nombre_categoria = DatosJson.nombre_categoria,
            id_estado = DatosJson.id_estado
        FROM OPENJSON(@DatosJson)
        WITH (
            idCategoriaProducto INT '$.idCategoriaProducto',
            nombre_categoria NVARCHAR(45) '$.nombre_categoria',
            id_estado INT '$.id_estado'
        ) AS DatosJson
        WHERE CategoriaProducto.idCategoriaProducto = DatosJson.idCategoriaProducto;

        -- Fetch the updated data
        SELECT
            'Completado' AS Estado,
            'Actualizado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM CategoriaProducto
                WHERE idCategoriaProducto IN (SELECT idCategoriaProducto FROM OPENJSON(@DatosJson) WITH (idCategoriaProducto INT '$.idCategoriaProducto'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

--  ========
-- 6. TABLA PRODUCTO
--  ========
-- Create: Insertar nuevos productos
CREATE PROCEDURE CrearProductos
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Declarar una tabla temporal para capturar los ids insertados
        DECLARE @IdsInsertados TABLE (idProducto INT);

        -- Insertar en la tabla Producto usando OPENJSON y capturar los ids insertados
        INSERT INTO Producto (nombre_producto, marca, codigo, stock, precio, foto, id_categoria_producto, id_estado)
        OUTPUT inserted.idProducto INTO @IdsInsertados
        SELECT 
            JSON_VALUE([value], '$.nombre_producto'),
            JSON_VALUE([value], '$.marca'),
            JSON_VALUE([value], '$.codigo'),
            JSON_VALUE([value], '$.stock'),
            JSON_VALUE([value], '$.precio'),
            CONVERT(varbinary(max), JSON_VALUE([value], '$.foto')),
            JSON_VALUE([value], '$.id_categoria_producto'),
            JSON_VALUE([value], '$.id_estado')
        FROM OPENJSON(@DatosJson);

        -- Retornar los datos insertados usando los ids capturados
        SELECT
            'Completado' AS Estado,
            'Insertado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Producto
                WHERE idProducto IN (SELECT idProducto FROM @IdsInsertados)
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

-- Read: Obtener información de múltiples productos por un array de IDs
CREATE PROCEDURE ObtenerProductos 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from Producto table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM Producto
                WHERE idProducto IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO


-- Update: Actualizar información de múltiples productos
CREATE PROCEDURE ActualizarProductos
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update Producto table using OPENJSON
        UPDATE Producto
        SET 
            nombre_producto = DatosJson.nombre_producto,
            marca = DatosJson.marca,
            codigo = DatosJson.codigo,
            stock = DatosJson.stock,
            precio = DatosJson.precio,
            foto = DatosJson.foto,
            id_categoria_producto = DatosJson.id_categoria_producto,
            id_estado = DatosJson.id_estado
        FROM OPENJSON(@DatosJson)
        WITH (
            idProducto INT '$.idProducto',
            nombre_producto NVARCHAR(100) '$.nombre_producto',
            marca NVARCHAR(45) '$.marca',
            codigo NVARCHAR(45) '$.codigo',
            stock FLOAT '$.stock',
            precio DECIMAL(10, 2) '$.precio',
            foto VARBINARY(MAX) '$.foto',
            id_categoria_producto INT '$.id_categoria_producto',
            id_estado INT '$.id_estado'
        ) AS DatosJson
        WHERE Producto.idProducto = DatosJson.idProducto;

        -- Fetch the updated data
        SELECT
            'Completado' AS Estado,
            'Actualizado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Producto
                WHERE idProducto IN (SELECT idProducto FROM OPENJSON(@DatosJson) WITH (idProducto INT '$.idProducto'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

--  ========
-- 7. TABLA ORDEN
--  ========

-- Create: Insertar una nueva orden con detalles
CREATE PROCEDURE CrearOrdenesConDetalle
    @OrdenJSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION
    BEGIN TRY
        -- Declare variables to hold parsed JSON data
        DECLARE @idOrden INT;
        DECLARE @totalOrden DECIMAL(10, 2);
        DECLARE @OrderDetails NVARCHAR(MAX) = JSON_QUERY(@OrdenJSON, '$.detalles');
        DECLARE @IdsInsertados TABLE (idOrden INT);

        -- Calculate the total from the details
        SET @totalOrden = (SELECT SUM(CONVERT(INT, JSON_VALUE(value, '$.cantidad')) * CONVERT(DECIMAL(10, 2), JSON_VALUE(value, '$.precio')))
                           FROM OPENJSON(@OrderDetails));

        -- Insert into Orden table with the calculated total
        INSERT INTO Orden (direccion_envio, telefono, correo_electronico, fecha_envio, total_orden, id_usuario, id_estado)
        OUTPUT inserted.idOrden INTO @IdsInsertados(idOrden)
        VALUES 
        (
            JSON_VALUE(@OrdenJSON, '$.direccion_envio'),
            JSON_VALUE(@OrdenJSON, '$.telefono'),
            JSON_VALUE(@OrdenJSON, '$.correo_electronico'),
            JSON_VALUE(@OrdenJSON, '$.fecha_envio'),
            @totalOrden,
            JSON_VALUE(@OrdenJSON, '$.id_usuario'),
            JSON_VALUE(@OrdenJSON, '$.id_estado')
        );

        -- Retrieve the idOrden from the table variable
        SET @idOrden = (SELECT TOP 1 idOrden FROM @IdsInsertados);

        -- Insert into OrdenDetalle table for each item in the detalles array
        INSERT INTO OrdenDetalle (cantidad, precio, id_orden, id_producto)
        SELECT 
            CONVERT(INT, JSON_VALUE(value, '$.cantidad')),
            CONVERT(DECIMAL(10, 2), JSON_VALUE(value, '$.precio')),
            @idOrden,
            JSON_VALUE(value, '$.id_producto')
        FROM OPENJSON(@OrderDetails);

        -- Commit the transaction
        COMMIT TRANSACTION;

        -- Return the new Order ID and total
        SELECT @idOrden AS NewOrderID, @totalOrden AS TotalOrden;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END
GO

-- Read: Obtener información de múltiples órdenes por IDs
CREATE PROCEDURE ObtenerOrdenes 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from Orden table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM Orden
                WHERE idOrden IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO


-- Update: Actualizar información de múltiples órdenes
CREATE PROCEDURE ActualizarOrdenes
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update Orden table using OPENJSON
        UPDATE Orden
        SET 
            direccion_envio = DatosJson.direccion_envio,
            telefono = DatosJson.telefono,
            correo_electronico = DatosJson.correo_electronico,
            fecha_envio = DatosJson.fecha_envio,
            total_orden = DatosJson.total_orden,
            id_usuario = DatosJson.id_usuario,
            id_estado = DatosJson.id_estado
        FROM OPENJSON(@DatosJson)
        WITH (
            idOrden INT '$.idOrden',
            direccion_envio NVARCHAR(255) '$.direccion_envio',
            telefono NVARCHAR(45) '$.telefono',
            correo_electronico NVARCHAR(100) '$.correo_electronico',
            fecha_envio DATE '$.fecha_envio',
            total_orden DECIMAL(10, 2) '$.total_orden',
            id_usuario INT '$.id_usuario',
            id_estado INT '$.id_estado'
        ) AS DatosJson
        WHERE Orden.idOrden = DatosJson.idOrden;

        -- Fetch the updated data
        SELECT
            'Completado' AS Estado,
            'Actualizado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM Orden
                WHERE idOrden IN (SELECT idOrden FROM OPENJSON(@DatosJson) WITH (idOrden INT '$.idOrden'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

--  ========
-- 8. TABLA ORDENDETALLE
--  ========
-- Read: Obtener información de múltiples detalles de órdenes por IDs
CREATE PROCEDURE ObtenerOrdenDetalles 
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        -- Fetch data from OrdenDetalle table
        DECLARE @ResultadoJson NVARCHAR(MAX);

        SELECT 
            'Completado' AS Estado,
            'Consulta exitosa' AS Mensaje,
            (
                SELECT 
                    *
                FROM OrdenDetalle
                WHERE id_OrdenDetalle IN (SELECT value FROM OPENJSON(@DatosJson))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END TRY
    BEGIN CATCH
        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END
GO

-- Update: Actualizar información de múltiples detalles de órdenes
CREATE PROCEDURE ActualizarOrdenDetalles
    @DatosJson NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRANSACTION
    BEGIN TRY
        -- Update OrdenDetalle table using OPENJSON
        UPDATE OD
        SET 
            cantidad = Datos.cantidad,
            precio = Datos.precio,
            id_orden = Datos.id_orden,
            id_producto = Datos.id_producto
        FROM OrdenDetalle OD
        JOIN OPENJSON(@DatosJson)
        WITH (
            id_OrdenDetalle INT '$.id_OrdenDetalle',
            cantidad INT '$.cantidad',
            precio DECIMAL(10, 2) '$.precio',
            id_orden INT '$.id_orden',
            id_producto INT '$.id_producto'
        ) AS Datos ON OD.id_OrdenDetalle = Datos.id_OrdenDetalle;

        -- Fetch the updated data
        SELECT
            'Completado' AS Estado,
            'Actualizado exitosamente' AS Mensaje,
            (
                SELECT 
                    *
                FROM OrdenDetalle
                WHERE id_OrdenDetalle IN (SELECT id_OrdenDetalle FROM OPENJSON(@DatosJson) WITH (id_OrdenDetalle INT '$.id_OrdenDetalle'))
                FOR JSON PATH
            ) AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction in case of error
        ROLLBACK TRANSACTION;

        -- Return error message
        SELECT
            'No completado' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS Datos
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
    END CATCH
END;
GO


-- ========================================
-- Insercion de datos de los procesos almacenados
-- tomando como ejemplo walmart
  
-- ========================================



-- ========================================
-- 2. Insercion de datos tabla	ESTADO
-- ========================================

EXEC InsertarEstado @nombre_estado = 'EstadoAactualizar';
EXEC InsertarEstado @nombre_estado = 'Inactivo';
EXEC InsertarEstado @nombre_estado = 'Pendiente';
EXEC InsertarEstado @nombre_estado = 'EstadoAeliminar';

EXEC ObtenerEstado @idEstado = 1;

EXEC ActualizarEstado @idEstado = 1, @nombre_estado = 'Activo';

EXEC EliminarEstado @idEstado = 4;




-- ========================================
-- 1. Insercion de datos tabla ROL
-- ========================================
-- ========================================
-- 1. Insercion de datos tabla ROL
-- ========================================
EXEC CrearRoles 
    @DatosJson = '[{ "nombre_rol": "Administrador" },
                   { "nombre_rol": "Usuario Final" },
                   { "nombre_rol": "Operador" },
                   { "nombre_rol": "UsuarioAeliminar" }]';


EXEC ObtenerRoles 
 @DatosJson = '[1]';
EXEC ActualizarRoles
   @DatosJson = '[ {"idRol": 1, "nombre_rol" : "Super Administrador", "id_estado": 1 }]';




-- ========================================
-- 3. Insercion de datos tabla	CLIENTES
-- ========================================

EXEC CrearClientes
@DatosJson =
'[
    {
        "razon_social": "Empresa A",
        "nombre_comercial": "Tienda 1",
        "direccion_envio": "5 calle 3-40",
        "telefono": "20440023",
        "correo_electronico": "contacto@empresaa.com"
    },
    {
        "razon_social": "Empresa B",
        "nombre_comercial": "Tienda 2",
        "direccion_envio": "5 calle 3-41",
        "telefono": "20440024",
        "correo_electronico": "contacto@empresaB.com"
    },
    {
        "razon_social": "Empresa C",
        "nombre_comercial": "Tienda 3",
        "direccion_envio": "5 calle 3-42",
        "telefono": "20440025",
        "correo_electronico": "contacto@empresaC.com"
    },
    {
        "razon_social": "Empresa D",
        "nombre_comercial": "Tienda 4",
        "direccion_envio": "5 calle 3-43",
        "telefono": "20440026",
        "correo_electronico": "contacto@empresaD.com"
    },
    {
        "razon_social": "Empresa E",
        "nombre_comercial": "Tienda 5",
        "direccion_envio": "5 calle 3-44",
        "telefono": "20440027",
        "correo_electronico": "contacto@empresaE.com"
    },
    {
        "razon_social": "Empresa F",
        "nombre_comercial": "Tienda 6",
        "direccion_envio": "5 calle 3-45",
        "telefono": "20440028",
        "correo_electronico": "contacto@empresaF.com"
    },
    {
        "razon_social": "Empresa G",
        "nombre_comercial": "Tienda 7",
        "direccion_envio": "5 calle 3-46",
        "telefono": "20440029",
        "correo_electronico": "contacto@empresaG.com"
    },
    {
        "razon_social": "Empresa H",
        "nombre_comercial": "Tienda 8",
        "direccion_envio": "5 calle 3-47",
        "telefono": "20440030",
        "correo_electronico": "contacto@empresaH.com"
    },
    {
        "razon_social": "Empresa I",
        "nombre_comercial": "Tienda 9",
        "direccion_envio": "5 calle 3-48",
        "telefono": "20440031",
        "correo_electronico": "contacto@empresaI.com"
    },
    {
        "razon_social": "Empresa J",
        "nombre_comercial": "Tienda 10",
        "direccion_envio": "5 calle 3-49",
        "telefono": "20440032",
        "correo_electronico": "contacto@empresaJ.com"
    },
    {
        "razon_social": "Empresa K",
        "nombre_comercial": "Tienda 11",
        "direccion_envio": "5 calle 3-50",
        "telefono": "20440033",
        "correo_electronico": "contacto@empresaK.com"
    },
    {
        "razon_social": "Empresa L",
        "nombre_comercial": "Tienda 12",
        "direccion_envio": "5 calle 3-51",
        "telefono": "20440034",
        "correo_electronico": "contacto@empresaL.com"
    },
    {
        "razon_social": "Empresa M",
        "nombre_comercial": "Tienda 13",
        "direccion_envio": "5 calle 3-52",
        "telefono": "20440035",
        "correo_electronico": "contacto@empresam.com"
    }
]';



EXEC ObtenerClientes  
 @DatosJson = '[1,2]';


 EXEC ActualizarClientes
   @DatosJson = '[ {"idCliente": 1, "razon_social" : "Empresa ABC", "nombre_comercial": "Tienda ABC", "direccion_envio": "Avenida Reforma 19-00","telefono": "22022020","correo_electronico": "contacto@tiendaabc.com" }]';

-- ========================================
-- 4. Insercion de datos tabla	USUARIO
-- ========================================

-- Insertar múltiples usuarios
EXEC CrearUsuarios 
    @DatosJson = N'[
        {
            "correo_electronico": "admin@test.com",
            "nombre_completo": "Administrador General",
            "contrasena_usuario": "admin123",
            "telefono": "34404040",
            "fecha_nacimiento": "1999-01-01",
            "id_rol": 1,
            "id_estado": 1
        },
        {
            "correo_electronico": "admin2@test.com",
            "nombre_completo": "Administrador General",
            "contrasena_usuario": "admin1234",
            "telefono": "40440000",
            "fecha_nacimiento": "1988-01-01",
            "id_rol": 1,
            "id_estado": 2
        },
        {
            "correo_electronico": "usuariofinal@test.com",
            "nombre_completo": "Administrador General",
            "contrasena_usuario": "admin123",
            "telefono": "32323344",
            "fecha_nacimiento": "1980-01-01",
            "id_rol": 2,
            "id_estado": 1
        }
    ]'


	-- Obtener múltiples usuarios por IDs
EXEC ObtenerUsuarios @DatosJson = N'[1, 2, 3]'

-- Actualizar múltiples usuarios
EXEC ActualizarUsuarios 
    @DatosJson = N'[
        {
            "idUsuario": 1,
            "correo_electronico": "administrador_actualizado@test.com",
            "nombre_completo": "Administrador Actualizado",
            "contrasena_usuario": "nuevacontrasena123",
            "telefono": "56093939",
            "fecha_nacimiento": "1985-06-15",
            "id_rol": 1,
            "id_estado": 1
        },
        {
            "idUsuario": 2,
            "correo_electronico": "admin2_actualizado@test.com",
            "nombre_completo": "Administrador Segundo Actualizado",
            "contrasena_usuario": "nueva1234",
            "telefono": "40441111",
            "fecha_nacimiento": "1988-02-01",
            "id_rol": 1,
            "id_estado": 2
        }
    ]'





-- Eliminar un usuario
-- EXEC EliminarUsuario @idUsuario = 3;



-- ========================================
-- 5. Insercion de datos tabla	CATEGORIAPRODUCTO
-- ========================================

-- Insertar múltiples categorías de productos
EXEC CrearCategoriaProductos
    @DatosJson = N'[
        {"nombre_categoria": "Accesorios", "id_estado": 2},
        {"nombre_categoria": "Zapatos", "id_estado": 2},
        {"nombre_categoria": "Juguetes", "id_estado": 1}
    ]'

	-- Obtener múltiples categorías de productos por IDs
EXEC ObtenerCategoriaProductos @DatosJson = N'[1, 2, 3]'


-- Actualizar múltiples categorías de productos
EXEC ActualizarCategoriaProductos
    @DatosJson = N'[
        {"idCategoriaProducto": 1, "nombre_categoria": "Ropa", "id_estado": 1},
        {"idCategoriaProducto": 2, "nombre_categoria": "Calzado", "id_estado": 1}
    ]'



-- ========================================
-- 6. Insercion de datos tabla	PRODUCTO
-- ========================================

-- Insertar múltiples productos
EXEC CrearProductos
    @DatosJson = '[
        {"nombre_producto": "Camiseta Azul1", "marca": "Marca X", "codigo": "C001", "stock": 22, "precio": 100.00, "foto": null, "id_categoria_producto": 1, "id_estado": 1},
        {"nombre_producto": "Camiseta Azul2", "marca": "Marca X", "codigo": "C002", "stock": 0, "precio": 150.00, "foto": null, "id_categoria_producto": 1, "id_estado": 1},
        {"nombre_producto": "Camiseta Azul3", "marca": "Marca X", "codigo": "C003", "stock": 50, "precio": 175.00, "foto": null, "id_categoria_producto": 1, "id_estado": 1},
        {"nombre_producto": "Zapato Azul", "marca": "Marca Y", "codigo": "C004", "stock": 50, "precio": 300.00, "foto": null, "id_categoria_producto": 1, "id_estado": 1}
    ]'


	-- Obtener múltiples productos por IDs
EXEC ObtenerProductos @DatosJson = N'[1, 2, 3, 4]'


-- Actualizar múltiples productos
EXEC ActualizarProductos
    @DatosJson = N'[
        {"idProducto": 1, "nombre_producto": "Zapato Negro", "marca": "Marca Y", "codigo": "Z004", "stock": 40, "precio": 300.00, "foto": NULL, "id_categoria_producto": 2, "id_estado": 1},
        {"idProducto": 2, "nombre_producto": "Camiseta Roja", "marca": "Marca X", "codigo": "C005", "stock": 30, "precio": 200.00, "foto": NULL, "id_categoria_producto": 1, "id_estado": 1}
    ]'


	-- ========================================
-- 7. Inserción de datos tabla ORDEN
-- ========================================

-- Declare the @OrdenJSON variable and set it to the first JSON order
DECLARE @OrdenJSON NVARCHAR(MAX);

-- First order
SET @OrdenJSON = N'{
    "direccion_envio": "Calle San Juan 23-3",
    "telefono": "43555552",
    "correo_electronico": "cliente@test.com",
    "fecha_envio": "2024-12-23",
    "id_usuario": 1,
    "id_estado": 1,
    "detalles": [
        {
            "cantidad": 2,
            "precio": 100.00,
            "id_producto": 1
        }
    ]
}';
EXEC CrearOrdenesConDetalle @OrdenJSON;

-- Second order
SET @OrdenJSON = N'{
    "direccion_envio": "Calle San Juan 23-3",
    "telefono": "43555552",
    "correo_electronico": "cliente@test.com",
    "fecha_envio": "2024-12-30",
    "id_usuario": 2,
    "id_estado": 1,
    "detalles": [
        {
            "cantidad": 2,
            "precio": 150.00,
            "id_producto": 4
        },
        {
            "cantidad": 4,
            "precio": 150.00,
            "id_producto": 4
        }
    ]
}';
EXEC CrearOrdenesConDetalle @OrdenJSON;

-- Third order (empty detalles array)
SET @OrdenJSON = N'{
    "direccion_envio": "Calle San Juan 23-4",
    "telefono": "43555552",
    "correo_electronico": "cliente@test.com",
    "fecha_envio": "2024-12-30",
    "id_usuario": 2,
    "id_estado": 2,
    "detalles": []
}';



-- Obtener múltiples órdenes por IDs
EXEC ObtenerOrdenes @DatosJson = N'[1, 2, 3]'

-- Actualizar múltiples órdenes
EXEC ActualizarOrdenes
    @DatosJson = N'[
        {
            "idOrden": 1,
            "direccion_envio": "45 calle zona 1",
            "telefono": "98765432",
            "correo_electronico": "cliente@test.com",
            "fecha_envio": "2024-12-15",
            "total_orden": 500,
            "id_usuario": 1,
            "id_estado": 1
        }
    ]'

-- ========================================
-- 8. Insercion de datos tabla	ORDENDETALLE
-- ========================================

-- Obtener múltiples detalles de órdenes por IDs
EXEC ObtenerOrdenDetalles @DatosJson = '[1, 2]'


-- Actualizar múltiples detalles de órdenes
EXEC ActualizarOrdenDetalles
    @DatosJson = '[
        {
            "id_OrdenDetalle": 1,
            "cantidad": 3,
            "precio": 45.99,
            "id_orden": 1,
            "id_producto": 1
        },
        {
            "id_OrdenDetalle": 2,
            "cantidad": 2,
            "precio": 50.00,
            "id_orden": 1,
            "id_producto": 2
        }
    ]'
GO


--===================================================================================
-- 6. Realización de Consultas (Dejar las consultas como  “vistas” en la base de datos,
-- no como archivos adicionales)
--===================================================================================

  -- a Total de Productos activos que tenga en stock mayor a 0 


CREATE VIEW TotalProductosActivos AS
SELECT COUNT(*) AS TotalProductos
FROM Producto
WHERE stock > 0 AND id_estado = (SELECT idEstado FROM Estado WHERE nombre_estado = 'Activo');
GO

SELECT * FROM TotalProductosActivos;

GO
--b Total de Quetzales en órdenes ingresadas en el mes de Diciembre 2024

CREATE VIEW TotalQuetzalesDiciembre2024 AS
SELECT SUM(total_orden) AS TotalOrdenes
FROM Orden
WHERE MONTH(fecha_creacion) = 12 AND YEAR(fecha_creacion) = 2024;
GO

SELECT TotalOrdenes FROM TotalQuetzalesDiciembre2024;


GO

--c  Top 10 de clientes con Mayor consumo de órdenes de todo el histórico

CREATE VIEW Top10ClientesMayorConsumo AS
SELECT TOP 10 c.idCliente, c.razon_social, SUM(o.total_orden) AS TotalConsumido
FROM Cliente c
JOIN Orden o ON c.idCliente = o.id_usuario
GROUP BY c.idCliente, c.razon_social
ORDER BY TotalConsumido DESC;
GO

SELECT * FROM Top10ClientesMayorConsumo;
GO

--d   Top 10 de productos más vendidos en orden ascendente

CREATE VIEW Top10ProductosMasVendidos AS
SELECT TOP 10 p.idProducto, p.nombre_producto, SUM(od.cantidad) AS TotalVendidos
FROM Producto p
JOIN OrdenDetalle od ON p.idProducto = od.id_producto
GROUP BY p.idProducto, p.nombre_producto
ORDER BY TotalVendidos ASC;
GO
SELECT * FROM Top10ProductosMasVendidos;
GO









