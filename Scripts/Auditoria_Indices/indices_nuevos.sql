-- Índices 

-- Consulta de préstamos por mes
use gestion_biblioteca_prueba;
go

set statistics io on;
set statistics time on;

select
    month(fecha_prestamo) as numero_mes,
    count(*) as total_prestamos
from dbo.Prestamo
where fecha_prestamo >= '2026-01-01'
  and fecha_prestamo < '2027-01-01'
group by month(fecha_prestamo)
order by numero_mes;

set statistics io off;
set statistics time off;


-- Consulta de top 10 socios con más préstamos 
set statistics io on;
set statistics time on;

select top (10)
    id_socio,
    count(*) as total_prestamos
from dbo.Prestamo
group by id_socio
order by total_prestamos desc, id_socio;

set statistics io off;
set statistics time off;


-- Consulta multas pendientes de pago 
set statistics io on;
set statistics time on;

select
    id_multa,
    id_prestamo,
    dias_retraso,
    monto_total,
    estado_pago
from dbo.Multa
where estado_pago = 'Pendiente';

set statistics io off;
set statistics time off;


-- Creación de los ínidces 

use gestion_biblioteca_prueba;
go


-- Para prestamo por mes 
create nonclustered index ix_prestamo_fecha
on dbo.Prestamo (fecha_prestamo)
include (id_socio, id_ejemplar, fecha_limite);
go


-- Top 10 socios con más prestamos 
create nonclustered index ix_prestamo_ranking_socios
on dbo.Prestamo (id_socio);


-- Multas pendinetes de pagar 
create nonclustered index ix_multa_estado_pago
on dbo.Multa (estado_pago)
include (id_prestamo, dias_retraso, monto_total);
go



