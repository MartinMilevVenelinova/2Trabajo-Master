# 🎬 Análisis SQL de Base de Datos de Películas

## 📖 Descripción del Proyecto
Este proyecto está basado en el análisis y explotación de una base de datos relacional de una tienda de películas ficticia.
Durante el trabajo se han realizado diferentes consultas SQL usando **DBeaver**, con conexión a **PostgreSQL**, para entender las tablas, sus relaciones y cómo extraer información relevante de ellas.

El objetivo principal ha sido aplicar los conocimientos aprendidos en el módulo de SQL, demostrando dominio de la herramienta, del lenguaje y de las buenas prácticas en la construcción de consultas limpias y funcionales.

---

## 📂 Estructura del repositorio

```
📁 Proyecto_SQL_Peliculas/
│
├── 📜 consultas_proyecto.sql # Archivo con las 64 consultas numeradas y comentadas
├── 📜 BBDD_Proyecto.sql # Script original de la base de datos
├── 🧾 README.md # Documento principal del proyecto
└── 📄 Documentación adicional.docx # Esquema de la BBDD y análisis complementario
```

---

## 🛠️ Instalación y Requisitos

Este proyecto no requiere instalación de librerías ni herramientas externas.  
Solo necesitas tener instalado y configurado el entorno de trabajo:

- 💻 **DBeaver 25.0.2** o una versión similar.  
- 🗄️ **PostgreSQL** como motor de base de datos.  
- 🧰 El archivo `BBDD_Proyecto.sql`, que contiene toda la estructura y los datos de la tienda de películas.

**Para ejecutar el análisis:**
1. Abre **DBeaver** e importa el archivo `BBDD_Proyecto.sql`.  
2. Crea una nueva conexión a **PostgreSQL** y ejecuta el script completo para generar las tablas y relaciones.  
3. Una vez importada la base de datos, abre el archivo `consultas_proyecto.sql`.  
4. Ejecuta las consultas individualmente (Ctrl + Enter) o por bloques, comprobando los resultados en el panel inferior.  
5. Puedes crear una vista ER (clic derecho sobre el esquema → *ER Diagram*) para visualizar la estructura completa de la base de datos.

---

## 🧠 Metodología, desarrollo y conclusiones
Antes de empezar con las consultas se revisó la base de datos, sus tablas y relaciones, para comprender la estructura completa.
Una vez entendida, se fueron resolviendo los enunciados uno a uno, comentando cada consulta para facilitar su lectura y entendimiento.

Durante todo el proyecto se aplicaron buenas prácticas como:
- Evitar `SELECT *` y especificar siempre las columnas necesarias.
- Usar alias claros y en español (por ejemplo: `"Título"`, `"Nombre completo"`).
- Formatear y alinear el código para hacerlo más legible.
- Emplear correctamente los distintos tipos de `JOIN`.
- Añadir comentarios explicando el funcionamiento de las partes más complejas.

### 🔍 Análisis general
Durante el desarrollo del proyecto se trabajó con más de 60 consultas diferentes, abarcando desde operaciones simples hasta uniones múltiples, subconsultas, vistas y tablas temporales.
Esto permitió no solo poner en práctica la sintaxis SQL, sino también entender la lógica relacional y las conexiones entre las distintas entidades de la base de datos.

Algunos resultados relevantes:
- Las categorías con más películas y alquileres son **Action** y **Comedy**.
- Se identificaron los **clientes más activos** y los que más dinero han gastado.
- Se calculó la duración media de los alquileres y el precio medio de las películas.
- También se verificó que todos los actores registrados participan en al menos una película, lo que demuestra la integridad del modelo.

### 🧾 Conclusión
El proyecto ha sido útil para consolidar el uso de SQL y del entorno DBeaver.
Se han trabajado consultas complejas, vistas, subconsultas y estructuras temporales, cumpliendo todos los requisitos del módulo.

Además, el trabajo permitió obtener una visión más analítica del negocio simulado, identificando patrones de clientes, categorías más activas y métricas relevantes para la gestión de la tienda.

---

## 💡 Ejemplo de consulta destacada
```sql
-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros
SELECT
    c.customer_id                          AS "ID cliente",
    CONCAT(c.first_name, ' ', c.last_name) AS "Nombre completo",
    ROUND(SUM(p.amount), 2)                AS "Total gastado (€)"
FROM public.customer AS c
JOIN public.payment AS p
  ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY "Total gastado (€)" DESC
LIMIT 5;
```

Esta consulta muestra los clientes más rentables, sumando el total gastado por cada uno.
Fue una de las consultas clave para entender los datos de facturación del sistema.

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas.  
Si deseas mejorar el dashboard o añadir nuevas visualizaciones:
1. Abre una *issue* o comentario con la propuesta.  
2. Explica brevemente el cambio sugerido.  
3. Si aplicable, comparte una versión actualizada del archivo Excel.  

---

## ✒️ Autores y Agradecimientos

**Autor:** Martin Milev Venelinova
**Formación:** Big Data Analytics  
