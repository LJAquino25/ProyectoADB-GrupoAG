-- ============================================================
-- 1. LIMPIEZA DE PERMISOS
-- Ejecutar antes de eliminar los roles.
-- ============================================================

USE gestion_biblioteca;
GO

-- Permisos del rol de consulta.
REVOKE SELECT ON OBJECT::catalogo.Libro FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::catalogo.Autor FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::catalogo.Categoria FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::catalogo.Editorial FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::catalogo.Libro_autor FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::catalogo.Ejemplar FROM rl_consulta_catalogo;

REVOKE SELECT ON OBJECT::usuarios.Socio FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::usuarios.Empleado FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::transacciones.Prestamo FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::transacciones.Multa FROM rl_consulta_catalogo;
REVOKE SELECT ON OBJECT::transacciones.Tarifa_multa FROM rl_consulta_catalogo;

REVOKE INSERT, UPDATE, DELETE
ON OBJECT::catalogo.Libro
FROM rl_consulta_catalogo;
GO

-- Permisos del rol de catálogo.
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Libro FROM rl_gestion_catalogo;
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Autor FROM rl_gestion_catalogo;
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Categoria FROM rl_gestion_catalogo;
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Editorial FROM rl_gestion_catalogo;
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Libro_autor FROM rl_gestion_catalogo;
REVOKE SELECT, INSERT, UPDATE ON OBJECT::catalogo.Ejemplar FROM rl_gestion_catalogo;
GO

-- Permisos del rol de préstamos.
REVOKE SELECT, INSERT, UPDATE
ON OBJECT::transacciones.Prestamo
FROM rl_gestion_prestamos;

REVOKE SELECT (id_socio)
ON OBJECT::usuarios.Socio
FROM rl_gestion_prestamos;

REVOKE SELECT (id_ejemplar)
ON OBJECT::catalogo.Ejemplar
FROM rl_gestion_prestamos;

REVOKE SELECT (id_empleado)
ON OBJECT::usuarios.Empleado
FROM rl_gestion_prestamos;
GO

-- Permisos del rol de multas.
REVOKE SELECT, INSERT, UPDATE
ON OBJECT::transacciones.Multa
FROM rl_gestion_multas;

REVOKE SELECT
ON OBJECT::transacciones.Tarifa_multa
FROM rl_gestion_multas;

REVOKE SELECT (id_prestamo)
ON OBJECT::transacciones.Prestamo
FROM rl_gestion_multas;
GO

-- Permisos del rol de auditoría.
REVOKE VIEW DEFINITION ON SCHEMA::catalogo FROM rl_auditoria;
REVOKE VIEW DEFINITION ON SCHEMA::usuarios FROM rl_auditoria;
REVOKE VIEW DEFINITION ON SCHEMA::transacciones FROM rl_auditoria;
GO


-- ============================================================
-- 2. LIMPIEZA DE ROLES
-- Ejecutar después de limpiar los permisos.
-- ============================================================

USE gestion_biblioteca;
GO

IF DATABASE_PRINCIPAL_ID('rl_consulta_catalogo') IS NOT NULL
BEGIN
    ALTER ROLE rl_consulta_catalogo DROP MEMBER usr_consulta;
    DROP ROLE rl_consulta_catalogo;
END
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_prestamos') IS NOT NULL
BEGIN
    ALTER ROLE rl_gestion_prestamos DROP MEMBER usr_prestamos;
    DROP ROLE rl_gestion_prestamos;
END
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_catalogo') IS NOT NULL
BEGIN
    ALTER ROLE rl_gestion_catalogo DROP MEMBER usr_catalogo;
    DROP ROLE rl_gestion_catalogo;
END
GO

IF DATABASE_PRINCIPAL_ID('rl_gestion_multas') IS NOT NULL
BEGIN
    ALTER ROLE rl_gestion_multas DROP MEMBER usr_multas;
    DROP ROLE rl_gestion_multas;
END
GO

IF DATABASE_PRINCIPAL_ID('rl_auditoria') IS NOT NULL
BEGIN
    ALTER ROLE rl_auditoria DROP MEMBER usr_auditor;
    DROP ROLE rl_auditoria;
END
GO


-- ============================================================
-- 3. LIMPIEZA DE USUARIOS
-- Ejecutar únicamente después de limpiar permisos y roles.
-- ============================================================

USE gestion_biblioteca;
GO

DROP USER IF EXISTS usr_auditor;
DROP USER IF EXISTS usr_consulta;
DROP USER IF EXISTS usr_prestamos;
DROP USER IF EXISTS usr_catalogo;
DROP USER IF EXISTS usr_multas;
GO


-- ============================================================
-- 4. ELIMINACION DE LOGINS
-- Ejecutar en master.
-- Los usuarios asociados deben haberse eliminado previamente
-- desde gestion_biblioteca.
-- ============================================================

USE master;
GO

IF SUSER_ID('login_consulta') IS NOT NULL
    DROP LOGIN login_consulta;
GO

IF SUSER_ID('login_prestamos') IS NOT NULL
    DROP LOGIN login_prestamos;
GO

IF SUSER_ID('login_catalogo') IS NOT NULL
    DROP LOGIN login_catalogo;
GO

IF SUSER_ID('login_multas') IS NOT NULL
    DROP LOGIN login_multas;
GO

-- COMPROBACION DE ELIMINACION DE LOGINS
SELECT name AS Login
FROM sys.server_principals
WHERE name IN (
    'login_consulta',
    'login_prestamos',
    'login_catalogo',
    'login_multas'
);
GO


