-- Auditorías 

-- Crear la tabla de auditoría 
use gestion_biblioteca;
go


if object_id('dbo.auditoria_biblioteca', 'U') is null
begin
create table dbo.auditoria_biblioteca (
    id_auditoria bigint identity(1,1) primary key,
    tabla_afectada varchar(100) not null,
    tipo_operacion varchar(10) not null,
    registro_afectado varchar(100) not null,
    usuario_sql sysname not null,
    fecha_operacion datetime2 not null
        default sysdatetime(),
    valores_anteriores nvarchar(max) null,
    valores_nuevos nvarchar(max) null,

    constraint chk_auditoria_operacion
        check (tipo_operacion in ('INSERT', 'UPDATE', 'DELETE'))
);
end;
go



--Trigger para prestamos
use gestion_biblioteca;
go

create or alter trigger dbo.tr_auditoria_prestamo
on dbo.prestamo
after insert, update, delete
as
begin
    set nocount on;

    insert into dbo.auditoria_biblioteca (
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        usuario_sql,
        fecha_operacion,
        valores_anteriores,
        valores_nuevos
    )
    select
        'Prestamo',

        case
            when d.id_prestamo is null then 'INSERT'
            when i.id_prestamo is null then 'DELETE'
            else 'UPDATE'
        end,

        cast(coalesce(i.id_prestamo, d.id_prestamo) as varchar(100)),

        original_login(),
        sysdatetime(),

        case
            when d.id_prestamo is not null
            then (
                select d.*
                for json path, without_array_wrapper
            )
            else null
        end,

        case
            when i.id_prestamo is not null
            then (
                select i.*
                for json path, without_array_wrapper
            )
            else null
        end

    from inserted i
    full outer join deleted d
        on i.id_prestamo = d.id_prestamo;
end;
go


--Trigger para socios
create or alter trigger dbo.tr_auditoria_socio
on dbo.socio
after insert, update, delete
as
begin
    set nocount on;

    insert into dbo.auditoria_biblioteca (
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        usuario_sql,
        fecha_operacion,
        valores_anteriores,
        valores_nuevos
    )
    select
        'Socio',
        case
            when d.id_socio is null then 'INSERT'
            when i.id_socio is null then 'DELETE'
            else 'UPDATE'
        end,
        cast(coalesce(i.id_socio, d.id_socio) as varchar(100)),
        original_login(),
        sysdatetime(),
        case
            when d.id_socio is not null
            then (select d.* for json path, without_array_wrapper)
            else null
        end,
        case
            when i.id_socio is not null
            then (select i.* for json path, without_array_wrapper)
            else null
        end
    from inserted i
    full outer join deleted d
        on i.id_socio = d.id_socio;
end;
go



--Trigger para libros
create or alter trigger dbo.tr_auditoria_libro
on dbo.libro
after insert, update, delete
as
begin
    set nocount on;

    insert into dbo.auditoria_biblioteca (
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        usuario_sql,
        fecha_operacion,
        valores_anteriores,
        valores_nuevos
    )
    select
        'Libro',
        case
            when d.isbn is null then 'INSERT'
            when i.isbn is null then 'DELETE'
            else 'UPDATE'
        end,
        coalesce(i.isbn, d.isbn),
        original_login(),
        sysdatetime(),
        case
            when d.isbn is not null
            then (select d.* for json path, without_array_wrapper)
            else null
        end,
        case
            when i.isbn is not null
            then (select i.* for json path, without_array_wrapper)
            else null
        end
    from inserted i
    full outer join deleted d
        on i.isbn = d.isbn;
end;
go



--Trigger para multas
create or alter trigger dbo.tr_auditoria_multa
on dbo.multa
after insert, update, delete
as
begin
    set nocount on;

    insert into dbo.auditoria_biblioteca (
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        usuario_sql,
        fecha_operacion,
        valores_anteriores,
        valores_nuevos
    )
    select
        'Multa',
        case
            when d.id_multa is null then 'INSERT'
            when i.id_multa is null then 'DELETE'
            else 'UPDATE'
        end,
        cast(coalesce(i.id_multa, d.id_multa) as varchar(100)),
        original_login(),
        sysdatetime(),
        case
            when d.id_multa is not null
            then (select d.* for json path, without_array_wrapper)
            else null
        end,
        case
            when i.id_multa is not null
            then (select i.* for json path, without_array_wrapper)
            else null
        end
    from inserted i
    full outer join deleted d
        on i.id_multa = d.id_multa;
end;
go


-- Verificar que existan 
use gestion_biblioteca;
go

select
    t.name as nombre_trigger,
    object_name(t.parent_id) as tabla,
    t.is_disabled as deshabilitado
from sys.triggers t
where t.name like 'tr_auditoria_%'
order by tabla;







