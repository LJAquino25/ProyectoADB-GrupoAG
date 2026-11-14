USE gestion_biblioteca

SELECT * FROM sys.schemas

/*
dbo.Autor - catalogo
dbo.Categoria - catalogo
dbo.Editorial - catalogo
dbo.Ejemplar - catalogo
dbo.Libro - catalogo
dbo.Libro_autor - catalogo

dbo.Empleado - usuarios
dbo.Socio - usuarios

dbo.Multa - transacciones
dbo.Prestamo - transacciones
dbo.Tarifa_multa - transacciones
*/

CREATE SCHEMA catalogo
CREATE SCHEMA usuarios
CREATE SCHEMA transacciones

ALTER SCHEMA catalogo TRANSFER dbo.Autor
ALTER SCHEMA catalogo TRANSFER dbo.Categoria
ALTER SCHEMA catalogo TRANSFER dbo.Editorial
ALTER SCHEMA catalogo TRANSFER dbo.Ejemplar
ALTER SCHEMA catalogo TRANSFER dbo.Libro
ALTER SCHEMA catalogo TRANSFER dbo.Libro_autor

ALTER SCHEMA usuarios TRANSFER dbo.Empleado
ALTER SCHEMA usuarios TRANSFER dbo.Socio

ALTER SCHEMA transacciones TRANSFER dbo.Multa
ALTER SCHEMA transacciones TRANSFER dbo.Prestamo
ALTER SCHEMA transacciones TRANSFER dbo.Tarifa_multa