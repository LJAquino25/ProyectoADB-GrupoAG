-- bloque 1: consultas simples (selección y filtros)

-- 1. lista todos los socios registrados en el sistema.

select * 
from socio;

-- 2. muestra los autores y su nacionalidad ordenados alfabeticamente.

select nombre, nacionalidad 
from autor 
order by nombre asc;

-- 3. busca libros que fueron publicados a partir del año 2000.

select isbn, titulo, anio_publicacion 
from libro 
where anio_publicacion >= 2000;

-- 4. filtra y muestra los socios que tienen estado inactivo.

select nombre, apellido, email 
from socio 
where estado = 'inactivo';

-- 5. muestra los identificadores de los ejemplares que estan disponibles.

select id_ejemplar, isbn 
from ejemplar 
where estado = 'disponible';

-- bloque 2: agrupación y uniones simples (joins)

-- 6. cuenta la cantidad total de libros registrados en la base.

select count(isbn) as total_libros 
from libro;

-- 7. calcula la suma total historica de todas las multas.

select sum(monto_total) as recaudacion_total
from multa;

-- 8. une libro y editorial para mostrar el titulo y quien lo publica.

select l.titulo, e.nombre as nombre_editorial
from libro l
inner join editorial e on l.id_editorial = e.id_editorial;

-- 9. muestra el detalle del prestamo junto con el nombre completo del socio.

select p.id_prestamo, s.nombre, s.apellido, p.fecha_prestamo
from prestamo p
inner join socio s on p.id_socio = s.id_socio;

-- 10. lista los libros y sus autores cruzando con la tabla intermedia.

select l.titulo, a.nombre as autor
from libro l
inner join libro_autor la on l.isbn = la.isbn
inner join autor a on la.id_autor = a.id_autor;

-- bloque 3: subconsultas (simples y correlacionadas)

-- 11. subconsulta en where: busca los libros cuyo autor es de nacionalidad colombiana.

select titulo, isbn 
from libro 
where isbn in (
    select la.isbn 
    from libro_autor la 
    inner join autor a on la.id_autor = a.id_autor 
    where a.nacionalidad = 'colombiana'
);

-- 12. subconsulta correlacionada: socios con deudas superiores al promedio general.

select s.nombre, s.apellido, m.monto_total
from socio s
inner join prestamo p on s.id_socio = p.id_socio
inner join multa m on p.id_prestamo = m.id_prestamo
where m.monto_total > (
    select avg(monto_total) from multa
);

-- 13. subconsulta en select: titulo del libro y cantidad de veces prestado.

select l.titulo, 
       (select count(*) 
        from prestamo p 
        inner join ejemplar e on p.id_ejemplar = e.id_ejemplar 
        where e.isbn = l.isbn) as total_veces_prestado
from libro l;

-- 14. exists: lista empleados que han gestionado prestamos que estan vencidos.

select emp.nombre, emp.cargo
from empleado emp
where exists (
    select 1 
    from prestamo p 
    where p.id_empleado_prestamo = emp.id_empleado and p.estado_prestamo = 'vencido'
);

-- 15. subconsulta en from: calcula el promedio de dias de retraso de todos los vencidos.

select avg(dias_retraso) as promedio_retraso_general
from (
    select datediff(day, fecha_limite, getdate()) as dias_retraso
    from prestamo 
    where estado_prestamo = 'vencido'
) as retrasos;

-- bloque 4: funciones de ventana (row_number, rank, over)

-- 16. row_number: numera los prestamos de cada socio cronologicamente.

select p.id_socio, s.nombre, p.fecha_prestamo,
       row_number() over(partition by p.id_socio order by p.fecha_prestamo desc) as orden_prestamo
from prestamo p
inner join socio s on p.id_socio = s.id_socio;

-- 17. rank: genera un ranking de categorias que tienen mas libros registrados.

select c.nombre_categoria, count(l.isbn) as total_libros,
       rank() over(order by count(l.isbn) desc) as ranking_categoria
from categoria c
inner join libro l on c.id_categoria = l.id_categoria
group by c.nombre_categoria;

-- 18. lag: compara la multa actual de un socio con el monto de su multa anterior.

select m.id_multa, p.id_socio, m.monto_total,
       lag(m.monto_total) over(partition by p.id_socio order by m.id_multa) as multa_anterior
from multa m
inner join prestamo p on m.id_prestamo = p.id_prestamo;

-- 19. sum over: calcula el acumulado progresivo de ingresos por multas pagadas ordenando por id.

select id_multa, monto_total, estado_pago,
       sum(monto_total) over(order by id_multa rows between unbounded preceding and current row) as ingresos_acumulados
from multa
where estado_pago = 'pagada';

-- 20. avg over: multa individual versus el promedio global en la misma fila.

select m.id_multa, p.id_socio, m.monto_total,
       avg(m.monto_total) over() as promedio_global_multas
from multa m
inner join prestamo p on m.id_prestamo = p.id_prestamo;

-- bloque 5: expresiones comunes de tabla (cte) y operadores de conjunto

-- 21. cte simple: aisla a los socios inactivos para consultar sus datos de contacto.

with sociosinactivos as (
    select id_socio, nombre, apellido, email, telefono 
    from socio 
    where estado = 'inactivo'
)
select * from sociosinactivos;

-- 22. cte multiple: compara totales de prestamos del 2025 versus 2026.

with prestamos2025 as (
    select count(*) as total_25 from prestamo where year(fecha_prestamo) = 2025
), prestamos2026 as (
    select count(*) as total_26 from prestamo where year(fecha_prestamo) = 2026
)
select total_25, total_26, (total_26 - total_25) as diferencia_crecimiento
from prestamos2025, prestamos2026;

-- 23. union all: unifica nombres de socios y empleados para un directorio general.

select nombre, 'socio' as tipo_perfil 
from socio
union all
select nombre, 'empleado' as tipo_perfil 
from empleado;

-- 24. except: encuentra socios registrados que nunca han realizado un prestamo.

select id_socio from socio
except
select id_socio from prestamo;

-- 25. intersect: ejemplares prestados tanto en enero como en febrero de 2026.

select id_ejemplar from prestamo where month(fecha_prestamo) = 1 and year(fecha_prestamo) = 2026
intersect
select id_ejemplar from prestamo where month(fecha_prestamo) = 2 and year(fecha_prestamo) = 2026;

-- bloque 6: pivot, json y funciones avanzadas

-- 26. pivot: transforma categorias en columnas para contar libros publicados en ciertos años.

select * from (
    select c.nombre_categoria, l.anio_publicacion, l.isbn
    from libro l
    inner join categoria c on l.id_categoria = c.id_categoria
) as datos_base
pivot (
    count(isbn) for anio_publicacion in ([2000], [2010], [2020])
) as tabla_pivoteada;

-- 27. json auto (simple): genera un objeto json con la informacion de los autores.

select id_autor, nombre, nacionalidad 
from autor 
for json auto;

-- 28. json auto (anidado): exporta libros con sus ejemplares anidados en formato json.

select l.isbn, l.titulo, e.id_ejemplar, e.estado
from libro l
inner join ejemplar e on l.isbn = e.isbn
for json auto;

-- 29. agrupacion avanzada: clasifica el estado del prestamo ignorando nulos.

select estado_prestamo, count(id_prestamo) as total_estado
from prestamo
group by estado_prestamo
having count(id_prestamo) > 0;

-- 30. case logico: etiqueta a los socios segun su morosidad.

select s.nombre, s.apellido, m.monto_total,
    case 
        when m.monto_total = 0 then 'sin deuda'
        when m.monto_total <= 5 then 'deuda leve'
        else 'deuda grave'
    end as clasificacion_morosidad
from socio s
inner join prestamo p on s.id_socio = p.id_socio
inner join multa m on p.id_prestamo = m.id_prestamo
where m.estado_pago = 'pendiente';