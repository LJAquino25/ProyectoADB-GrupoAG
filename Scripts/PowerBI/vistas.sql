use gestion_biblioteca;
go

--VISTA 1 - Préstamos por mes (2026) 
--Índice: ix_prestamo_fecha (fecha_prestamo)
create or alter view dbo.vw_prestamos_por_mes as
select
    year(fecha_prestamo)  as anio,
    month(fecha_prestamo) as numero_mes,
    count(*)              as total_prestamos
from dbo.Prestamo
group by year(fecha_prestamo), month(fecha_prestamo);
go
alter view dbo.vw_prestamos_por_mes as
select
    year(fecha_prestamo)  as anio,
    month(fecha_prestamo) as numero_mes,
    count(*)              as total_prestamos
from dbo.Prestamo
where fecha_prestamo >= '2026-01-01'
  and fecha_prestamo <  '2027-01-01'
group by year(fecha_prestamo), month(fecha_prestamo);
go

--VISTA 2 - Top 10 socios con más préstamos
--Índice: ix_prestamo_ranking_socios (id_socio)
create view or alter  dbo.vw_top10_socios as
select top (10)
    p.id_socio,
    s.nombre,
    count(*) as total_prestamos
from dbo.Prestamo p
join dbo.Socio s on s.id_socio = p.id_socio
group by p.id_socio, s.nombre
order by total_prestamos desc, p.id_socio;
go

--VISTA 3 - Multas pendientes
--Índice: ix_multa_pendiente (estado_pago)
create or alter view  dbo.vw_multas_pendientes as
select
    id_multa,
    id_prestamo,
    dias_retraso,
    monto_total,
    estado_pago,
    case
        when dias_retraso <= 15 then '1-15 días'
        when dias_retraso <= 30 then '16-30 días'
        when dias_retraso <= 60 then '31-60 días'
        else 'Más de 60 días'
    end as rango_retraso,
    case
        when dias_retraso <= 15 then 1
        when dias_retraso <= 30 then 2
        when dias_retraso <= 60 then 3
        else 4
    end as orden_rango
from dbo.Multa
where estado_pago = 'Pendiente';
go