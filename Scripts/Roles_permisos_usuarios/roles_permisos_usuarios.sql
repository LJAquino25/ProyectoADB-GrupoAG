


-- ============================================================
-- GESTION DE USUARIOS
-- BASE DE DATOS: gestion_biblioteca
-- ============================================================

-- 1.1 CREACION DE LOGINS
-- Ejecutar en master.
-- IMPORTANTE: Los logins deben crearse antes que los usuarios
-- asociados dentro de la base de datos.

USE master;
GO

IF SUSER_ID('login_consulta') IS NULL
    CREATE LOGIN login_consulta
    WITH PASSWORD = 'Cambiar_Consulta#2026', CHECK_POLICY = ON;
GO

IF SUSER_ID('login_prestamos') IS NULL
    CREATE LOGIN login_prestamos
    WITH PASSWORD = 'Cambiar_Prestamos#2026', CHECK_POLICY = ON;
GO

IF SUSER_ID('login_catalogo') IS NULL
    CREATE LOGIN login_catalogo
    WITH PASSWORD = 'Cambiar_Catalogo#2026', CHECK_POLICY = ON;
GO

IF SUSER_ID('login_multas') IS NULL
    CREATE LOGIN login_multas
    WITH PASSWORD = 'Cambiar_Multas#2026', CHECK_POLICY = ON;
GO


-- 1.2 CREACION DE USUARIOS ASOCIADOS A LOGINS
-- Ejecutar después de crear los logins.
-- Cada usuario representa una identidad dentro de la base de datos.

USE gestion_biblioteca;
GO

IF DATABASE_PRINCIPAL_ID('usr_consulta') IS NULL
    CREATE USER usr_consulta FOR LOGIN login_consulta;
GO

IF DATABASE_PRINCIPAL_ID('usr_prestamos') IS NULL
    CREATE USER usr_prestamos FOR LOGIN login_prestamos;
GO

IF DATABASE_PRINCIPAL_ID('usr_catalogo') IS NULL
    CREATE USER usr_catalogo FOR LOGIN login_catalogo;
GO

IF DATABASE_PRINCIPAL_ID('usr_multas') IS NULL
    CREATE USER usr_multas FOR LOGIN login_multas;
GO


-- 1.3 CREACION DE USUARIO SIN LOGIN
-- Este usuario no necesita un login del servidor.
-- Se utilizará para representar al responsable de auditoría.
-- Suplantación y asignación de rol se realizarán posteriormente.

IF DATABASE_PRINCIPAL_ID('usr_auditor') IS NULL
    CREATE USER usr_auditor WITHOUT LOGIN;
GO


-- 1.4 COMPROBACION DE USUARIOS
-- Permite verificar los usuarios creados y su autenticación.

SELECT
    name AS Usuario,
    type_desc AS TipoUsuario,
    authentication_type_desc AS TipoAutenticacion
FROM sys.database_principals
WHERE name IN (
    'usr_consulta',
    'usr_prestamos',
    'usr_catalogo',
    'usr_multas',
    'usr_auditor'
);
GO


-- 1.5 COMPROBACION DE RELACION ENTRE LOGINS Y USUARIOS MEDIANTE SID
-- Los usuarios asociados a logins deben tener el mismo SID.
-- El usuario sin login debe aparecer sin correspondencia.

SELECT
    dp.name AS Usuario,
    sp.name AS Login,
    CASE
        WHEN sp.sid IS NULL THEN 'SIN LOGIN ASOCIADO'
        WHEN dp.sid = sp.sid THEN 'SID COINCIDENTE'
        ELSE 'SID DIFERENTE'
    END AS Estado
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp
    ON dp.sid = sp.sid
WHERE dp.name IN (
    'usr_consulta',
    'usr_prestamos',
    'usr_catalogo',
    'usr_multas',
    'usr_auditor'
);
GO




-- ============================================================
-- GESTION DE ROLES
-- BASE DE DATOS: gestion_biblioteca
-- ============================================================

USE gestion_biblioteca;
GO


-- 2.1 CREACION DE ROLES PERSONALIZADOS
-- Ejecutar después de crear los usuarios.
-- Los roles permiten centralizar los permisos según las
-- responsabilidades de cada usuario.

IF DATABASE_PRINCIPAL_ID('rl_consulta_catalogo') IS NULL
    CREATE ROLE rl_consulta_catalogo;
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_prestamos') IS NULL
    CREATE ROLE rl_gestion_prestamos;
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_catalogo') IS NULL
    CREATE ROLE rl_gestion_catalogo;
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_multas') IS NULL
    CREATE ROLE rl_gestion_multas;
GO

IF DATABASE_PRINCIPAL_ID('rl_auditoria') IS NULL
    CREATE ROLE rl_auditoria;
GO


-- 2.2 ASIGNACION DE USUARIOS A ROLES
-- Ejecutar después de crear los roles.
-- Cada usuario recibe el rol correspondiente a sus funciones.
-- Se comprueba la pertenencia para evitar asignaciones duplicadas.

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'rl_consulta_catalogo'
      AND u.name = 'usr_consulta'
)
    ALTER ROLE rl_consulta_catalogo ADD MEMBER usr_consulta;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'rl_gestion_prestamos'
      AND u.name = 'usr_prestamos'
)
    ALTER ROLE rl_gestion_prestamos ADD MEMBER usr_prestamos;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'rl_gestion_catalogo'
      AND u.name = 'usr_catalogo'
)
    ALTER ROLE rl_gestion_catalogo ADD MEMBER usr_catalogo;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'rl_gestion_multas'
      AND u.name = 'usr_multas'
)
    ALTER ROLE rl_gestion_multas ADD MEMBER usr_multas;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u
        ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'rl_auditoria'
      AND u.name = 'usr_auditor'
)
    ALTER ROLE rl_auditoria ADD MEMBER usr_auditor;
GO


-- 2.3 COMPROBACION DE ROLES Y USUARIOS ASIGNADOS
-- Permite verificar la relación entre cada usuario y su rol.

SELECT
    r.name AS Rol,
    u.name AS Usuario
FROM sys.database_role_members drm
INNER JOIN sys.database_principals r
    ON drm.role_principal_id = r.principal_id
INNER JOIN sys.database_principals u
    ON drm.member_principal_id = u.principal_id
WHERE r.name IN (
    'rl_consulta_catalogo',
    'rl_gestion_prestamos',
    'rl_gestion_catalogo',
    'rl_gestion_multas',
    'rl_auditoria'
)
ORDER BY r.name, u.name;
GO

-- ============================================================
-- Creacion de SCHEMAS 
-- BASE DE DATOS: gestion_biblioteca
-- ============================================================
--Inicie la ejecucion de los SCHEMAS para que funcione correctamente la gestion de permisos


-- ============================================================
-- GESTION DE PERMISOS (AJUSTADO A NUEVOS ESQUEMAS)
-- BASE DE DATOS: gestion_biblioteca
-- ============================================================

USE gestion_biblioteca;
GO


-- 3.1 CONCESION DE PERMISOS DE LECTURA (GRANT)

GRANT SELECT ON OBJECT::catalogo.Libro TO rl_consulta_catalogo;
GRANT SELECT ON OBJECT::catalogo.Autor TO rl_consulta_catalogo;
GRANT SELECT ON OBJECT::catalogo.Categoria TO rl_consulta_catalogo;
GRANT SELECT ON OBJECT::catalogo.Editorial TO rl_consulta_catalogo;
GRANT SELECT ON OBJECT::catalogo.Libro_autor TO rl_consulta_catalogo;
GRANT SELECT ON OBJECT::catalogo.Ejemplar TO rl_consulta_catalogo;
GO


-- 3.2 PERMISOS DE GESTION DEL CATALOGO

GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Libro TO rl_gestion_catalogo;
GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Autor TO rl_gestion_catalogo;
GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Categoria TO rl_gestion_catalogo;
GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Editorial TO rl_gestion_catalogo;
GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Libro_autor TO rl_gestion_catalogo;
GRANT SELECT, INSERT, UPDATE ON OBJECT::catalogo.Ejemplar TO rl_gestion_catalogo;
GO


-- 3.3 PERMISOS DE GESTION DE PRESTAMOS

GRANT SELECT, INSERT, UPDATE
ON OBJECT::transacciones.Prestamo
TO rl_gestion_prestamos;
GO

GRANT SELECT (id_socio)
ON OBJECT::usuarios.Socio
TO rl_gestion_prestamos;
GO

GRANT SELECT (id_ejemplar)
ON OBJECT::catalogo.Ejemplar
TO rl_gestion_prestamos;
GO

USE gestion_biblioteca;
GO

GRANT SELECT (id_empleado)
ON OBJECT::usuarios.Empleado
TO rl_gestion_prestamos;
GO

-- 3.4 PERMISOS DE GESTION DE MULTAS

GRANT SELECT, INSERT, UPDATE
ON OBJECT::transacciones.Multa
TO rl_gestion_multas;
GO

GRANT SELECT
ON OBJECT::transacciones.Tarifa_multa
TO rl_gestion_multas;
GO

GRANT SELECT (id_prestamo)
ON OBJECT::transacciones.Prestamo
TO rl_gestion_multas;
GO


-- 3.5 DENEGACION DE PERMISOS (DENY)

DENY SELECT ON OBJECT::usuarios.Socio TO rl_consulta_catalogo;
DENY SELECT ON OBJECT::usuarios.Empleado TO rl_consulta_catalogo;
DENY SELECT ON OBJECT::transacciones.Prestamo TO rl_consulta_catalogo;
DENY SELECT ON OBJECT::transacciones.Multa TO rl_consulta_catalogo;
DENY SELECT ON OBJECT::transacciones.Tarifa_multa TO rl_consulta_catalogo;
GO

DENY INSERT, UPDATE, DELETE
ON OBJECT::catalogo.Libro
TO rl_consulta_catalogo;
GO


-- 3.6 PERMISOS A NIVEL DE ESQUEMA

GRANT VIEW DEFINITION ON SCHEMA::catalogo TO rl_auditoria;
GRANT VIEW DEFINITION ON SCHEMA::usuarios TO rl_auditoria;
GRANT VIEW DEFINITION ON SCHEMA::transacciones TO rl_auditoria;
GO


-- 3.7 REVOCACION DE PERMISOS (REVOKE)

GRANT UPDATE
ON OBJECT::transacciones.Tarifa_multa
TO rl_gestion_multas;
GO

REVOKE UPDATE
ON OBJECT::transacciones.Tarifa_multa
FROM rl_gestion_multas;
GO


-- 3.8 COMPROBACION DE PERMISOS MEDIANTE HAS_PERMS_BY_NAME

EXECUTE AS USER = 'usr_consulta';

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('catalogo.Libro', 'OBJECT', 'SELECT')
        AS PuedeConsultarLibros,
    HAS_PERMS_BY_NAME('usuarios.Socio', 'OBJECT', 'SELECT')
        AS PuedeConsultarSocios,
    HAS_PERMS_BY_NAME('usuarios.Empleado', 'OBJECT', 'SELECT')
        AS PuedeConsultarEmpleados,
    HAS_PERMS_BY_NAME('catalogo.Libro', 'OBJECT', 'UPDATE')
        AS PuedeModificarLibros;

REVERT;
GO


-- 3.9 COMPROBACION DE PERMISOS A NIVEL DE COLUMNA

EXECUTE AS USER = 'usr_prestamos';

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME(
        'usuarios.Socio', 'OBJECT', 'SELECT', 'id_socio', 'COLUMN'
    ) AS PuedeConsultarIdSocio,
    HAS_PERMS_BY_NAME(
        'usuarios.Socio', 'OBJECT', 'SELECT'
    ) AS PuedeConsultarTodaLaTabla;

REVERT;
GO


-- 3.10 COMPROBACION MEDIANTE fn_my_permissions

EXECUTE AS USER = 'usr_prestamos';

SELECT *
FROM fn_my_permissions('transacciones.Prestamo', 'OBJECT');

REVERT;
GO


-- 3.11 SUPLANTACION DE USUARIOS (EXECUTE AS USER)

EXECUTE AS USER = 'usr_catalogo';

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('catalogo.Libro', 'OBJECT', 'INSERT')
        AS PuedeInsertarLibros,
    HAS_PERMS_BY_NAME('catalogo.Libro', 'OBJECT', 'UPDATE')
        AS PuedeActualizarLibros,
    HAS_PERMS_BY_NAME('transacciones.Prestamo', 'OBJECT', 'INSERT')
        AS PuedeInsertarPrestamos;

REVERT;
GO

EXECUTE AS USER = 'usr_multas';

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('transacciones.Multa', 'OBJECT', 'INSERT')
        AS PuedeRegistrarMultas,
    HAS_PERMS_BY_NAME('transacciones.Tarifa_multa', 'OBJECT', 'SELECT')
        AS PuedeConsultarTarifas,
    HAS_PERMS_BY_NAME('transacciones.Tarifa_multa', 'OBJECT', 'UPDATE')
        AS PuedeModificarTarifas;

REVERT;
GO

EXECUTE AS USER = 'usr_auditor';

SELECT
    USER_NAME() AS UsuarioActual,
    HAS_PERMS_BY_NAME('catalogo', 'SCHEMA', 'VIEW DEFINITION')
        AS PuedeConsultarMetadatosCatalogo,
    HAS_PERMS_BY_NAME('usuarios', 'SCHEMA', 'VIEW DEFINITION')
        AS PuedeConsultarMetadatosUsuarios,
    HAS_PERMS_BY_NAME('transacciones', 'SCHEMA', 'VIEW DEFINITION')
        AS PuedeConsultarMetadatosTransacciones;

REVERT;
GO  