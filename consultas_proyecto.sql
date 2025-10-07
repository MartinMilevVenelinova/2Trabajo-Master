-- 1. Crea el esquema de la BBDD.
DROP SCHEMA IF EXISTS videostore CASCADE;
CREATE SCHEMA videostore AUTHORIZATION CURRENT_USER;
SET search_path TO videostore

-- 2. Muestra los nombres de todas las películas con una clasificación por
-- edades de ‘R’.

SELECT 	f.title 		AS "Titulo"
FROM public.film AS f
WHERE f.rating = 'R'
ORDER BY f.title;

-- 3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30
-- y 40.

SELECT	a.actor_id 		AS "ID", 	
		CONCAT(a.first_name, ' ' ,
		a.last_name) 	AS "Nombre completo"
FROM public.actor AS a
WHERE a.actor_id BETWEEN 30 AND 40
ORDER BY a.actor_id;

-- 4. Obtén las películas cuyo idioma coincide con el idioma original.
/*
SELECT
  f.film_id,
  f.title,
  l."name", 
FROM public.film AS f, public.language AS l
ORDER BY f.title;*/

SELECT	f.film_id		AS "ID",
  		f.title 		AS "Titulo",
  		lang.name		AS "Lenguaje",
  		COALESCE(lang0.name, lang.name) AS "Lenguaje Original"
FROM public.film 		AS f
JOIN public.language 	AS lang
  ON lang.language_id = f.language_id
LEFT JOIN public.language AS lang0
  ON lang0.language_id = f.original_language_id
WHERE f.language_id = COALESCE(f.original_language_id, f.language_id)
ORDER BY f.title;

-- 5. Ordena las películas por duración de forma ascendente.

SELECT 	f.film_id		AS "ID",
    	f.title			AS "Título",
    	f.length		AS "Duración (min)"
FROM public.film AS f
ORDER BY "Duración (min)" ASC, "Título";

-- 6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su
-- apellido.

SELECT 	a.actor_id 		AS "ID",
    CONCAT(a.first_name, ' ' ,
	a.last_name) 		AS "Nombre completo"
FROM public.actor AS a
WHERE a.last_name ILIKE '%Allen%'
ORDER BY "Nombre completo";

-- 7. Encuentra la cantidad total de películas en cada clasificación de la tabla
-- “film” y muestra la clasificación junto con el recuento.

SELECT 	f.rating        AS "Clasificación",
    	COUNT(*)        AS "Total de películas"
FROM public.film AS f
GROUP BY f.rating
ORDER BY "Total de películas" DESC, "Clasificación";

-- 8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una
-- duración mayor a 3 horas en la tabla film.

SELECT 	f.film_id   	AS "ID",
    	f.title     	AS "Título",
    	f.rating    	AS "Clasificación",
    	ROUND(f.length / 60.0, 2)	AS "Duración (hora)"
FROM public.film AS f
WHERE f.rating = 'PG-13'
   OR f.length > 180
ORDER BY "Duración (hora)" DESC, "Título";

-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.

SELECT 
    VAR_POP(f.replacement_cost) AS "Costo de remplazo"
FROM public.film AS f;

-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.

SELECT 	MIN(f.length) 	AS "Duración mínima (min)",
    	MAX(f.length) 	AS "Duración máxima (min)"
FROM public.film AS f;

-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.

WITH alquileres_con_pos AS (
  SELECT
      r.rental_id,
      DATE(r.rental_date) AS dia,
      r.rental_date       AS ts_alquiler,
      ROW_NUMBER() OVER (
        PARTITION BY DATE(r.rental_date)
        ORDER BY r.rental_date DESC
      ) AS pos_dentro_del_dia
  FROM public.rental AS r
)
SELECT	a.rental_id    	AS "ID alquiler",
		a.dia        	AS "Día",
    	a.ts_alquiler 	AS "Fecha-hora alquiler",
    	COALESCE(SUM(p.amount), 0)	AS "Coste (€)"
FROM alquileres_con_pos AS a
LEFT JOIN public.payment AS p
  ON p.rental_id = a.rental_id
WHERE a.pos_dentro_del_dia = 3
GROUP BY a.dia, a.ts_alquiler, a.rental_id
ORDER BY "Día" ASC, "Fecha-hora alquiler" ASC;

-- 12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC17’ ni ‘G’ en cuanto a su clasificación.

SELECT 	f.film_id   	AS "ID",
    	f.title     	AS "Título",
    	f.rating    	AS "Clasificación"
FROM public.film AS f
WHERE f.rating NOT IN ('NC-17', 'G')
ORDER BY "Título";

/* 13. Encuentra el promedio de duración de las películas para cada
clasificación de la tabla film y muestra la clasificación junto con el
promedio de duración */

SELECT 	f.rating       	AS "Clasificación",
    	ROUND(AVG(f.length), 2)	AS "Promedio de duración (min)"
FROM public.film AS f
GROUP BY f.rating
ORDER BY "Promedio de duración (min)" DESC, "Clasificación";

-- 14. Encuentra el título de todas las películas que tengan una duración mayor
-- a 180 minutos.

SELECT 	f.film_id	AS "ID",
    	f.title   	AS "Título",
    	f.length   	AS "Duración (min)"
FROM public.film AS f
WHERE f.length > 180
ORDER BY "Duración (min)" DESC, "Título";

-- 15. ¿Cuánto dinero ha generado en total la empresa?

SELECT SUM(p.amount) AS "Ingresos totales (€)"
FROM public.payment AS p;

-- 16. Muestra los 10 clientes con mayor valor de id.

SELECT 	ROW_NUMBER() OVER (ORDER BY c.customer_id DESC) AS "Top 10",
    	CONCAT(c.first_name, ' ' ,
		c.last_name)	AS "Nombre completo",
    	c.customer_id  	AS "ID cliente"
FROM public.customer AS c
ORDER BY c.customer_id DESC
LIMIT 10;

-- 17. Encuentra el nombre y apellido de los actores que aparecen en la
-- película con título ‘Egg Igby’

/*SELECT f.film_id, f.title
FROM public.film AS f
WHERE f.title = 'Egg Igby';

SELECT f.film_id, f.title
FROM public.film AS f
WHERE TRIM(f.title) ILIKE '%egg%' OR TRIM(f.title) ILIKE '%igby%'
ORDER BY f.title;*/

SELECT 	a.actor_id 		AS "ID actor",
    	CONCAT(a.first_name, ' ' ,
		a.last_name)	AS "Nombre completo"
FROM public.actor AS a
JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
JOIN public.film AS f
  ON f.film_id = fa.film_id
WHERE f.title ILIKE 'Egg Igby'
ORDER BY "Nombre completo";

-- 18. Selecciona todos los nombres de las películas únicos

SELECT DISTINCT
    f.title AS "Título"
FROM public.film AS f
ORDER BY "Título";

-- 19. Encuentra el título de las películas que son comedias y tienen una
-- duración mayor a 180 minutos en la tabla “film”

SELECT 	f.film_id 	 	AS "ID",
    	f.title    		AS "Título",
    	f.length 		AS "Duración (min)",
    	c.name    		AS "Categoría"
FROM public.film AS f
JOIN public.film_category AS fc
  ON fc.film_id = f.film_id
JOIN public.category AS c
  ON c.category_id = fc.category_id
WHERE c.name = 'Comedy'
  AND f.length > 180
ORDER BY "Duración (min)" DESC, "Título";

/* 20. Encuentra las categorías de películas que tienen un promedio de
duración superior a 110 minutos y muestra el nombre de la categoría
junto con el promedio de duración.*/

SELECT	c.name    		AS "Categoría",
    	ROUND(AVG(f.length), 2)	AS "Promedio de duración (min)"
FROM public.category AS c
JOIN public.film_category AS fc
  ON fc.category_id = c.category_id
JOIN public.film AS f
  ON f.film_id = fc.film_id
GROUP BY c.name
HAVING AVG(f.length) > 110
ORDER BY "Promedio de duración (min)" DESC, "Categoría";

-- 21. ¿Cuál es la media de duración del alquiler de las películas?

SELECT 	ROUND(AVG(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 86400), 2)
    	AS "Media de duración del alquiler (días)"
FROM public.rental AS r
WHERE r.return_date IS NOT NULL;

-- 22. Crea una columna con el nombre y apellidos de todos los actores y
-- actrices.

SELECT 	a.actor_id  	AS "ID actor",
    	CONCAT(a.first_name, ' ' ,
		a.last_name)	AS "Nombre completo"
FROM public.actor AS a
ORDER BY "Nombre completo";

-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de
-- forma descendente.

SELECT	DATE(r.rental_date)	AS "Día",
    	COUNT(*)			AS "Número de alquileres"
FROM public.rental AS r
GROUP BY DATE(r.rental_date)
ORDER BY "Número de alquileres" DESC, "Día" ASC;

-- 24. Encuentra las películas con una duración superior al promedio.

/* SELECT ROUND(AVG(f.length), 2) AS "Promedio de duración (min)"
FROM public.film AS f; */

SELECT 	f.film_id         	AS "ID",
    	f.title      		AS "Título",
    	f.length          	AS "Duración (min)"
FROM public.film AS f
WHERE f.length > (SELECT AVG(f2.length) FROM public.film AS f2)
ORDER BY "Duración (min)" DESC, "Título";

-- 25. Averigua el número de alquileres registrados por mes.

SELECT	TO_CHAR(DATE_TRUNC('month', r.rental_date), 'YYYY-MM') AS "Mes",
    	COUNT(*)                                               AS "Número de alquileres"
FROM public.rental AS r
GROUP BY DATE_TRUNC('month', r.rental_date)
ORDER BY "Mes";

-- 26. Encuentra el promedio, la desviación estándar y varianza del total pagado.

SELECT 	ROUND(AVG(p.amount), 2)        	AS "Promedio (€)",
    	ROUND(STDDEV_POP(p.amount), 2) 	AS "Desviación estándar",
    	ROUND(VAR_POP(p.amount), 2)    	AS "Varianza"
FROM public.payment AS p;

-- 27. ¿Qué películas se alquilan por encima del precio medio?

/*SELECT 
    ROUND(AVG(f.rental_rate), 2) AS "Precio medio alquiler (€)"
FROM public.film AS f;*/

SELECT	f.film_id   		AS "ID",
    	f.title     		AS "Título",
    	f.rental_rate 		AS "Precio alquiler (€)"
FROM public.film AS f
WHERE f.rental_rate > (SELECT AVG(f2.rental_rate) FROM public.film AS f2)
ORDER BY "Precio alquiler (€)" DESC, "Título";

-- 28. Muestra el id de los actores que hayan participado en más de 40
-- películas.

SELECT 	a.actor_id         					AS "ID actor",
    	CONCAT(a.first_name, ' ' ,
		a.last_name)	AS "Nombre completo",
    	COUNT(fa.film_id)                   AS "Número de películas"
FROM public.actor AS a
JOIN public.film_actor AS fa 
  ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(fa.film_id) > 40
ORDER BY "Número de películas" DESC, "Nombre completo";

-- 29. Obtener todas las películas y, si están disponibles en el inventario,
-- mostrar la cantidad disponible.

SELECT	f.film_id   		AS "ID",
    	f.title     		AS "Título",
    	COUNT(i.inventory_id) FILTER (WHERE public.inventory_in_stock(i.inventory_id)) 
        AS "Unidades disponibles"
FROM public.film AS f
LEFT JOIN public.inventory AS i 
  ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY "Unidades disponibles" DESC, "Título";

-- 30. Obtener los actores y el número de películas en las que ha actuado.

SELECT	CONCAT(a.first_name, ' ' ,
		a.last_name)	AS "Nombre completo",
    	COUNT(fa.film_id)                 	AS "Número de películas"
FROM public.actor AS a
LEFT JOIN public.film_actor AS fa 
  ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY "Número de películas" DESC, "Nombre completo";

-- 31. Obtener todas las películas y mostrar los actores que han actuado en
-- ellas, incluso si algunas películas no tienen actores asociados.

SELECT	f.title       	AS "Título",
    	COALESCE(
	    STRING_AGG(CONCAT(a.first_name, ' ', a.last_name), ', ' ORDER BY a.last_name, a.first_name),
	      	'(sin actores)'
	    )				AS "Participantes"
FROM public.film AS f
LEFT JOIN public.film_actor AS fa
  ON fa.film_id = f.film_id
LEFT JOIN public.actor AS a
  ON a.actor_id = fa.actor_id
GROUP BY f.film_id, f.title
ORDER BY "Título";

/* 32. Obtener todos los actores y mostrar las películas en las que han
actuado, incluso si algunos actores no han actuado en ninguna película. */

SELECT	CONCAT(a.first_name, ' ', a.last_name)	AS "Nombre completo",
    	COALESCE(
      	STRING_AGG(f.title, ', ' ORDER BY f.title),
      		'(sin películas)'
    	)                                      	AS "Películas"
FROM public.actor AS a
LEFT JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
LEFT JOIN public.film AS f
  ON f.film_id = fa.film_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY "Nombre completo";

-- 33. Obtener todas las películas que tenemos y todos los registros de
-- alquiler

SELECT	f.title            AS "Título",
	    r.rental_id        AS "ID alquiler",
	    r.rental_date      AS "Fecha de alquiler",
	    r.return_date      AS "Fecha de devolución"
FROM public.film AS f
FULL JOIN public.inventory AS i
  ON i.film_id = f.film_id
FULL JOIN public.rental AS r
  ON r.inventory_id = i.inventory_id
ORDER BY "Título" NULLS FIRST, "Fecha de alquiler" NULLS LAST;

-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.

SELECT	CONCAT(c.first_name, ' ', c.last_name)      AS "Nombre completo",
    	ROUND(SUM(p.amount), 2)                     AS "Total gastado (€)"
FROM public.customer AS c
JOIN public.payment AS p
  ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Total gastado (€)" DESC, "Nombre completo"
LIMIT 5;

-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.

SELECT	CONCAT(a.first_name, ' ', a.last_name) 		AS "Nombre completo"
FROM public.actor AS a
WHERE a.first_name ILIKE 'johnny'
ORDER BY "Nombre completo";

-- 36. Renombra la columna “first_name” como Nombre y “last_name” como
-- Apellido.

SELECT	a.first_name 		AS "Nombre",
    	a.last_name  		AS "Apellido"
FROM public.actor AS a
ORDER BY "Apellido", "Nombre";

-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor.

SELECT 	MIN(a.actor_id) 	AS "ID actor más bajo",
    	MAX(a.actor_id) 	AS "ID actor más alto"
FROM public.actor AS a;

-- 38. Cuenta cuántos actores hay en la tabla “actor”.

SELECT	COUNT(*) AS "Número total de actores"
FROM public.actor AS a;

-- 39. Selecciona todos los actores y ordénalos por apellido en orden
-- ascendente.

SELECT 	a.first_name       	AS "Nombre",
		a.last_name        	AS "Apellido"	 	
FROM public.actor AS a
ORDER BY a.last_name ASC, a.first_name ASC;

-- 40. Selecciona las primeras 5 películas de la tabla “film”.

SELECT 	f.film_id   		AS "ID película",
	    f.title     		AS "Título",
	    f.release_year 		AS "Año de estreno",
	    f.rating    		AS "Clasificación",
	    f.length    		AS "Duración (min)"
FROM public.film AS f
ORDER BY f.film_id
LIMIT 5;

-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el
-- mismo nombre. ¿Cuál es el nombre más repetido? 

SELECT 	a.first_name     	AS "Nombre",
    	COUNT(*)           	AS "Cantidad de actores"
FROM public.actor AS a
GROUP BY a.first_name
HAVING COUNT(*) >= 2
ORDER BY "Cantidad de actores" DESC, "Nombre";

-- 42. Encuentra todos los alquileres y los nombres de los clientes que los
-- realizaron.

SELECT 	r.rental_id                          	AS "ID alquiler",
    	CONCAT(c.first_name, ' ', c.last_name) 	AS "Nombre completo cliente"
FROM public.rental AS r
JOIN public.customer AS c
  ON c.customer_id = r.customer_id
ORDER BY "Fecha de alquiler" DESC, "ID alquiler";

-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo
-- aquellos que no tienen alquileres.

SELECT	CONCAT(c.first_name, ' ', c.last_name) 	AS "Nombre completo",
    	r.rental_id                            	AS "ID alquiler"
FROM public.customer AS c
LEFT JOIN public.rental AS r
  ON r.customer_id = c.customer_id
ORDER BY "Nombre completo";

-- 44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor
-- esta consulta? ¿Por qué? Deja después de la consulta la contestación.

/*No aporta valor, porque un CROSS JOIN entre "film" y "category" no aporta
  valor práctico en este contexto, porque genera el producto cartesiano: 
  todas las combinaciones posibles entre películas y categorías, sin tener
  en cuenta su relación real 
  Esto hace que tenga un valor inflado que no refleja informacion útil */

SELECT 	f.title      		AS "Título",
    	c.name       		AS "Categoría"
FROM public.film AS f
CROSS JOIN public.category AS c
ORDER BY "Título", "Categoría";

-- 45. Encuentra los actores que han participado en películas de la categoría
-- 'Action'.

SELECT DISTINCT	f.title 								AS "Pelicula",
    			CONCAT(a.first_name, ' ', a.last_name) 	AS "Nombre completo"
FROM public.actor AS a
JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
JOIN public.film AS f
  ON f.film_id = fa.film_id
JOIN public.film_category AS fc
  ON fc.film_id = f.film_id
JOIN public.category AS c
  ON c.category_id = fc.category_id
WHERE c.name = 'Action'
ORDER BY "Nombre completo";

-- 46. Encuentra todos los actores que no han participado en películas. (Datos Nulos)

SELECT	a.actor_id                             	AS "ID actor",
    	CONCAT(a.first_name, ' ', a.last_name) 	AS "Nombre completo"
FROM public.actor AS a
LEFT JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
WHERE fa.film_id IS NULL
ORDER BY "Nombre completo";

-- 47. Selecciona el nombre de los actores y la cantidad de películas en las
-- que han participado.

SELECT	CONCAT(a.first_name, ' ', a.last_name) 	AS "Nombre completo",
    	COUNT(fa.film_id)                       AS "Número de películas"
FROM public.actor AS a
LEFT JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
GROUP BY a.first_name, a.last_name
ORDER BY "Número de películas" DESC, "Nombre completo";

-- 48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres
-- de los actores y el número de películas en las que han participado.

CREATE OR REPLACE VIEW public.actor_num_peliculas AS
SELECT	a.actor_id                             	AS "ID actor",
    	CONCAT(a.first_name, ' ', a.last_name) 	AS "Nombre completo",
    	COUNT(fa.film_id)                      	AS "Número de películas"
FROM public.actor AS a
LEFT JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY "Número de películas" DESC, "Nombre completo";

SELECT *
FROM public.actor_num_peliculas
LIMIT 10;

-- 49. Calcula el número total de alquileres realizados por cada cliente.

SELECT	CONCAT(c.first_name, ' ', c.last_name) AS "Nombre completo",
    	COUNT(r.rental_id)                     AS "Número de alquileres"
FROM public.customer AS c
LEFT JOIN public.rental AS r
  ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Número de alquileres" DESC, "Nombre completo";

-- 50. Calcula la duración total de las películas en la categoría 'Action'.

SELECT 	c.name                  		AS "Categoría",
    	SUM(f.length)           		AS "Duración total (min)",
    	ROUND(SUM(f.length) / 60.0, 2) 	AS "Duración total (horas)"
FROM public.category AS c
JOIN public.film_category AS fc
  ON fc.category_id = c.category_id
JOIN public.film AS f
  ON f.film_id = fc.film_id
WHERE c.name = 'Action'
GROUP BY c.name;

-- 51. Crea una tabla temporal llamada “cliente_rentas_temporal” para
-- almacenar el total de alquileres por cliente.

CREATE TEMP TABLE cliente_rentas_temporal AS
SELECT	c.customer_id                          	AS "ID cliente",
    	CONCAT(c.first_name, ' ', c.last_name) 	AS "Nombre completo",
    	COUNT(r.rental_id)                     	AS "Total de alquileres"
FROM public.customer AS c
LEFT JOIN public.rental AS r
  ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Total de alquileres" DESC;

SELECT * FROM cliente_rentas_temporal;

-- 52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las
-- películas que han sido alquiladas al menos 10 veces.

CREATE TEMP TABLE peliculas_alquiladas AS
SELECT	f.film_id   		AS "ID película",
    	f.title     		AS "Título",
    COUNT(r.rental_id) AS "Número de alquileres"
FROM public.film AS f
JOIN public.inventory AS i
  ON i.film_id = f.film_id
JOIN public.rental AS r
  ON r.inventory_id = i.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) >= 10
ORDER BY "Número de alquileres" DESC, "Título";

SELECT * FROM peliculas_alquiladas;

/* 53. Encuentra el título de las películas que han sido alquiladas por el cliente
con el nombre ‘Tammy Sanders’ y que aún no se han devuelto. Ordena
los resultados alfabéticamente por título de película. */

SELECT 	f.film_id 		AS "ID película",
    	f.title   		AS "Título"
FROM public.customer AS c
JOIN public.rental AS r
  ON r.customer_id = c.customer_id
JOIN public.inventory AS i
  ON i.inventory_id = r.inventory_id
JOIN public.film AS f
  ON f.film_id = i.film_id
WHERE c.first_name ILIKE 'Tammy'
  AND c.last_name ILIKE 'Sanders'
  AND r.return_date IS NULL
ORDER BY "Título";

/* 54. Encuentra los nombres de los actores que han actuado en al menos una
película que pertenece a la categoría ‘Sci-Fi’. Ordena los resultados
alfabéticamente por apellido. */

SELECT DISTINCT a.first_name		AS "Nombre",
    			a.last_name 		AS "Apellido"
FROM public.actor AS a
JOIN public.film_actor AS fa
  ON fa.actor_id = a.actor_id
JOIN public.film AS f
  ON f.film_id = fa.film_id
JOIN public.film_category AS fc
  ON fc.film_id = f.film_id
JOIN public.category AS c
  ON c.category_id = fc.category_id
WHERE c.name = 'Sci-Fi'
ORDER BY a.last_name ASC, a.first_name ASC;


/* 55. Encuentra el nombre y apellido de los actores que han actuado en
películas que se alquilaron después de que la película ‘Spartacus
Cheaper’ se alquilara por primera vez. Ordena los resultados
alfabéticamente por apellido. */

WITH primera_renta AS (
    SELECT MIN(r.rental_date) AS fecha_primera_renta
    FROM public.rental AS r
    JOIN public.inventory AS i  ON i.inventory_id = r.inventory_id
    JOIN public.film AS f       ON f.film_id = i.film_id
    WHERE f.title ILIKE 'Spartacus Cheaper'
)
SELECT DISTINCT f.title			AS "Pelicula",
    			a.last_name		AS "Apellido",
    			a.first_name   	AS "Nombre"
FROM public.actor AS a
JOIN public.film_actor AS fa  ON fa.actor_id = a.actor_id
JOIN public.film AS f         ON f.film_id   = fa.film_id
JOIN public.inventory AS i    ON i.film_id   = f.film_id
JOIN public.rental AS r       ON r.inventory_id = i.inventory_id
CROSS JOIN primera_renta pr
WHERE r.rental_date > pr.fecha_primera_renta
ORDER BY "Apellido", "Nombre";

/* 56. Encuentra el nombre y apellido de los actores que no han actuado en
ninguna película de la categoría ‘Music’. */

SELECT
    a.actor_id                             AS "ID actor",
    CONCAT(a.first_name, ' ', a.last_name) AS "Nombre completo"
FROM public.actor AS a
WHERE NOT EXISTS (
    SELECT 1
    FROM public.film_actor   AS fa
    JOIN public.film_category AS fc ON fc.film_id    = fa.film_id
    JOIN public.category      AS c  ON c.category_id = fc.category_id
    WHERE fa.actor_id = a.actor_id
      AND c.name = 'Music'
)
ORDER BY "Nombre completo";

-- 57. Encuentra el título de todas las películas que fueron alquiladas por más
-- de 8 días.

SELECT DISTINCT	f.film_id 		AS "ID película",
    			f.title   		AS "Título"
FROM public.rental   AS r
JOIN public.inventory AS i ON i.inventory_id = r.inventory_id
JOIN public.film      AS f ON f.film_id      = i.film_id
WHERE r.return_date IS NOT NULL
  AND EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 86400 > 8
ORDER BY "Título";

/* 58. Encuentra el título de todas las películas que son de la misma categoría
que ‘Animation’.*/

SELECT DISTINCT	f.film_id 		AS "ID película",
    			f.title   		AS "Título"
FROM public.film AS f
JOIN public.film_category AS fc
  ON fc.film_id = f.film_id
JOIN public.category AS c
  ON c.category_id = fc.category_id
WHERE c.name = 'Animation'
ORDER BY "Título";

/* 59. Encuentra los nombres de las películas que tienen la misma duración
que la película con el título ‘Dancing Fever’. Ordena los resultados
alfabéticamente por título de película. */

SELECT	f.film_id 		AS "ID película",
    	f.title   		AS "Título",
    	f.length  		AS "Duración (min)"
FROM public.film AS f
WHERE f.length = (
    SELECT f2.length
    FROM public.film AS f2
    WHERE f2.title ILIKE 'Dancing Fever'
)
ORDER BY "Título";

/* 60. Encuentra los nombres de los clientes que han alquilado al menos 7
películas distintas. Ordena los resultados alfabéticamente por apellido.*/

SELECT	CONCAT(c.first_name, ' ', c.last_name) 	AS "Nombre completo",
    	COUNT(DISTINCT f.film_id)              	AS "Películas distintas alquiladas"
FROM public.customer AS c
JOIN public.rental AS r
  ON r.customer_id = c.customer_id
JOIN public.inventory AS i
  ON i.inventory_id = r.inventory_id
JOIN public.film AS f
  ON f.film_id = i.film_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT f.film_id) >= 7
ORDER BY c.last_name ASC, c.first_name ASC;

/* 61. Encuentra la cantidad total de películas alquiladas por categoría y
muestra el nombre de la categoría junto con el recuento de alquileres.*/

SELECT 	c.name               	AS "Categoría",
    	COUNT(r.rental_id)   	AS "Total de alquileres"
FROM public.category AS c
JOIN public.film_category AS fc
  ON fc.category_id = c.category_id
JOIN public.film AS f
  ON f.film_id = fc.film_id
JOIN public.inventory AS i
  ON i.film_id = f.film_id
JOIN public.rental AS r
  ON r.inventory_id = i.inventory_id
GROUP BY c.name
ORDER BY "Total de alquileres" DESC, "Categoría";

-- 62. Encuentra el número de películas por categoría estrenadas en 2006

SELECT 	c.name              	AS "Categoría",
    	COUNT(f.film_id)    	AS "Número de películas (2006)"
FROM public.category AS c
JOIN public.film_category AS fc
  ON fc.category_id = c.category_id
JOIN public.film AS f
  ON f.film_id = fc.film_id
WHERE f.release_year = 2006
GROUP BY c.name
ORDER BY "Número de películas (2006)" DESC, "Categoría";

/* 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas
que tenemos.*/

SELECT	s.staff_id                          	AS "ID empleado",
    	CONCAT(s.first_name, ' ', s.last_name) 	AS "Nombre empleado",
    	st.store_id                         	AS "ID tienda"
FROM public.staff AS s
CROSS JOIN public.store AS st
ORDER BY "Nombre empleado", "ID tienda";

/* 64. Encuentra la cantidad total de películas alquiladas por cada cliente y
muestra el ID del cliente, su nombre y apellido junto con la cantidad de
películas alquiladas. */

SELECT	c.customer_id                          	AS "ID cliente",
    	CONCAT(c.first_name, ' ', c.last_name) 	AS "Nombre completo",
    	COUNT(r.rental_id)                     	AS "Películas alquiladas"
FROM public.customer AS c
LEFT JOIN public.rental AS r
  ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Películas alquiladas" DESC, "Nombre completo";
