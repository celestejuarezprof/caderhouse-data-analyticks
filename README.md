# RetailPro - Base de Datos Ventas_Tech_DB

## Descripción del proyecto

Este repositorio contiene el script SQL correspondiente al proyecto **RetailPro**, desarrollado en el marco del curso de Data Analytics de Coderhouse.

El objetivo de este checkpoint es construir el **back-end** del proyecto final: una base de datos relacional, normalizada (3NF) y con integridad referencial, que sirva como fuente de datos para el futuro dashboard de Business Intelligence. Esta base modela las operaciones de venta de **TechStore**, una cadena de tiendas de tecnología.

## Modelo de datos

La base de datos `Ventas_Tech_DB` está compuesta por 4 tablas relacionadas:
categorias (1) ──── (N) productos (1) ──── (N) ventas (N) ──── (1) clientes

- **categorias**: categorías de productos (ej. Computación, Accesorios, Audio, Almacenamiento)
- **clientes**: datos de los clientes de la tienda
- **productos**: catálogo de productos, cada uno asociado a una categoría
- **ventas**: tabla de hechos que registra cada transacción, vinculando cliente y producto

## Contenido del script (`ventas_tech_db.sql`)

El archivo incluye tres secciones:

1. **DROP TABLES**: elimina las tablas existentes (en orden inverso de dependencias) para permitir una ejecución repetible.
2. **CREATE TABLES**: define las 4 tablas con sus tipos de datos, PRIMARY KEYs, FOREIGN KEYs y restricciones (NOT NULL, UNIQUE, DEFAULT).
3. **INSERT DATA**: carga inicial con 4 categorías, 5 clientes, 6 productos y 10 ventas.

## Cómo ejecutar el script

**Requisitos:** SQL Server Management Studio (SSMS) con una instancia de SQL Server activa.

1. Cloná o descargá este repositorio.
2. Abrí SQL Server Management Studio y conectate a tu instancia.
3. Abrí el archivo `ventas_tech_db.sql` directamente desde SSMS (`Archivo > Abrir > Archivo...`), para evitar problemas de caracteres invisibles al copiar y pegar.
4. Ejecutá el script completo (`Execute` o F5).
5. El script crea la base `Ventas_Tech_DB`, sus tablas y carga los datos automáticamente.

### Verificar que todo cargó bien

```sql
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
```

Deberías ver 4 categorías, 5 clientes, 6 productos y 10 ventas.

## Estado

✅ Script probado y ejecutado sin errores en SQL Server (SSMS).
✅ Integridad referencial validada (Foreign Keys en `productos` y `ventas`).

## Próximos pasos

- **Módulo 6**: conexión de Power BI a esta base de datos para limpieza y transformación.
- **Módulo 8**: construcción del modelo analítico y medidas DAX.

## Autora 
juarez celeste 


## Módulo 4 - Consultas de negocio (`m4_consultas_negocio.sql`)

Este script contiene 4 consultas SQL sobre `Ventas_Tech_DB` orientadas a responder preguntas de negocio:

1. **Resumen ejecutivo mensual**: total facturado, cantidad de pedidos y ticket promedio por mes.
2. **Ranking de productos**: Top 5 productos por total facturado, con unidades vendidas.
3. **Clientes recurrentes**: clientes con más de un pedido, ordenados por gasto total.
4. **Meses por encima/por debajo del promedio**: compara la facturación de cada mes contra el promedio general, usando un CTE (`WITH`).

### Cómo ejecutarlo

Requiere haber corrido antes `ventas_tech_db.sql`, ya que trabaja sobre esa misma base de datos.

1. Abrí `m4_consultas_negocio.sql` en SSMS.
2. Ejecutá el script completo (F5) o consulta por consulta.

### Hallazgos principales

- El producto 1 concentra el 55,9% de la facturación total, muy por encima del segundo puesto (21%).
- Tener más de un pedido no implica ser cliente de alto valor: el gasto entre clientes recurrentes varía mucho (de $510 a $2.640).
- Las 10 ventas cargadas caen todas en marzo de 2024, por lo que la comparación mensual (Consulta 4) todavía no es representativa — haría falta cargar datos de varios meses para un análisis de estacionalidad real.

### Nota de compatibilidad

La consigna original sugiere `EXTRACT(MONTH FROM fecha_venta)` (sintaxis PostgreSQL). En SQL Server se usó el equivalente `MONTH(fecha_venta)`.



Módulo 5 - Consultas con JOINs (m5_consultas_joins.sql)

Las consultas de M4 trabajaban sobre tablas individuales. En este módulo se cruzan para obtener una vista enriquecida (ventas + cliente + producto + categoría + región), que es la fuente de datos principal para el dashboard de Power BI (M7).

Ampliación del esquema

La consigna de M5 requería campos que la base original (M3) no tenía todavía, así que este script primero amplía el esquema antes de las consultas:


Tabla nueva territorios: id_territorio, nombre_region (AMBA, Centro, Litoral, Cuyo, NOA).
clientes: se agregan las columnas segmento (Premium / Standard) e id_territorio (FK a territorios).
ventas: se agrega la columna canal (Online / Presencial).
Se completan estos datos para los clientes y ventas ya cargados en M3.
Se agregan 2 clientes nuevos sin compras (Jorge Medina, Sofía Paz), para poder demostrar la Consulta 2 con resultados reales.


Las 4 consultas


Vista base del proyecto (INNER JOIN): combina ventas, clientes, productos, categorias y territorios en una sola fila por venta — fecha, cliente, segmento, región, producto, categoría, cantidad, precio, total y canal.
Clientes sin ventas (LEFT JOIN): clientes registrados que todavía no compraron nada, usando WHERE ... IS NULL.
Productos sin ventas (LEFT JOIN): productos del catálogo sin ninguna venta registrada. En los datos actuales, el único caso es el SSD Externo 1TB.
Consolidado por canal (UNION ALL): combina las ventas Online y Presencial en un solo resultado y calcula el total facturado por canal con GROUP BY.


Cómo ejecutarlo

Requiere haber corrido antes ventas_tech_db.sql (M3), ya que amplía esa misma base de datos.


Abrí m5_consultas_joins.sql directamente en SSMS.
Ejecutá el script completo (F5). Primero corre la ampliación de esquema y después las 4 consultas, mostrando sus resultados en orden.


Resultados esperados



Módulo 6 - Conectividad y transformación en Power BI (documentacion_m6_power_query.md)

Contexto y fuente de datos

El archivo de origen (Production_resultado_en_sql.xlsx) es un reporte exportado desde un sistema legacy de producción, con 1141 filas y 14 columnas. Combina en una sola tabla datos de producto (nombre, color, costo, precio, categoría) con datos de ubicación de depósito — un mismo producto puede estar guardado en más de un lugar, por lo que aparece repetido varias veces con distinta ubicación en cada fila.

1. Carga del archivo

Se utilizó el conector Excel de Power BI Desktop (Obtener datos → Excel), seleccionando la hoja única del archivo y entrando directamente a Transformar datos para trabajar en el Editor de Power Query antes de cargar el modelo final.

2. Transformaciones realizadas (en orden)

a) Renombrado de columnas
Se reemplazaron los nombres técnicos del sistema original (ProductID, NAME, STOCK_RECOMENDADO, etc.) por nombres descriptivos en snake_case y en español: id_producto, nombre_producto, color, stock_recomendado, punto_reposicion, costo, precio, dias_fabricacion, fecha_inicio_venta, fecha_fin_venta, subcategoria, categoria, id_ubicacion, nombre_ubicacion.

b) Corrección de tipos de datos

ColumnaTipo asignadoJustificaciónid_producto, id_ubicacionNúmero enteroIdentificadores, sin decimalesstock_recomendado, punto_reposicion, dias_fabricacionNúmero enteroCantidades discretascosto, precioNúmero decimalValores monetarios que requieren precisión decimalfecha_inicio_venta, fecha_fin_ventaFechaNecesario para poder filtrar y calcular por tiempo en el modelonombre_producto, color, subcategoria, categoria, nombre_ubicacionTextoDatos categóricos/descriptivos, no se usan en cálculos numéricos

c) Detección de un problema no evidente: "NULL" como texto literal

Al revisar los datos, se detectó que las celdas vacías del archivo original no eran nulos reales, sino el texto literal "NULL" (en mayúsculas), típico de exportaciones de sistemas legacy. Esto se confirmó porque Power Query mostraba el valor en negro normal (NULL) en vez del formato gris/cursiva (null) que usa para nulos verdaderos.

Este detalle tuvo dos consecuencias distintas:


En columnas de texto (color, subcategoria, categoria, nombre_ubicacion), el texto "NULL" se cargaba sin error, pero como un valor más de la columna — había que reemplazarlo explícitamente.
En columnas de fecha (fecha_fin_venta), el intento de convertir el texto "NULL" a tipo Fecha generaba un error de conversión (DataFormat.Error), ya que "NULL" no es una fecha válida.


d) Gestión de nulos y duplicados

Se aplicó un criterio distinto según el significado real de cada campo, no una regla única:


color: 688 casos con "NULL" → reemplazados por "Sin color". Corresponde a productos (tornillos, rodamientos, piezas metálicas) para los que el atributo color no aplica.
subcategoria / categoria: 609 casos cada una → reemplazados por "Sin categorizar". Son insumos o componentes sin categoría comercial asignada en el sistema origen.
nombre_ubicacion: reemplazado por "Sin ubicación asignada" en los casos con "NULL".
id_ubicacion: se dejó sin modificar (nulo real, no un texto reemplazado). No se justifica inventar un ID numérico (como 0), ya que podría interpretarse como una ubicación real inexistente.
fecha_fin_venta: se dejó intencionalmente en nulo (no se reemplazó por texto ni por una fecha ficticia). Un nulo en esta columna tiene un significado de negocio válido: el producto sigue vigente a la venta y todavía no tiene fecha de baja. Reemplazarlo distorsionaría cualquier análisis de vigencia de catálogo. Los casos que generaban error de conversión de tipo se resolvieron con "Reemplazar errores" → null, para normalizarlos como nulo real sin perder ese significado.
Duplicados: no existían filas 100% duplicadas en el archivo original. Lo que sí ocurría era que un mismo id_producto aparecía repetido porque el producto tiene más de una ubicación de depósito — esto no es un duplicado a eliminar, sino una relación uno-a-muchos legítima entre producto y ubicación. Este caso se resolvió normalizando la estructura (ver punto siguiente), no borrando filas.


e) Normalización: separación en dos tablas

Siguiendo el mismo criterio que separar datos de cliente y de transacción, se identificaron dos tipos de información mezclados en la tabla original:


Atributos del producto (fijos, no cambian entre filas de un mismo id_producto)
Atributos de la ubicación (variables, cambian según el depósito)


Se crearon dos consultas independientes en Power Query:


productos: un registro único por id_producto, con el resto de los atributos (nombre, color, costo, precio, fechas, categoría, subcategoría). Se aplicó "Quitar duplicados" sobre id_producto luego de sacar las columnas de ubicación, quedando 504 productos únicos.
producto_ubicaciones: tabla de relación con id_producto, id_ubicacion y nombre_ubicacion, con 1141 filas (una por cada combinación producto-ubicación). Acá sí es correcto y esperable que se repita el id_producto.


3. Resultado final


El archivo carga sin errores en Power BI Desktop.
Las 14 columnas originales quedaron distribuidas en 2 tablas relacionadas por id_producto, cada una con nombres descriptivos y tipos de datos correctos.
No quedan filas completamente vacías ni duplicados no justificados.
Los nulos que subsisten (fecha_fin_venta, id_ubicacion) son intencionales y documentados, no datos faltantes sin resolver.


Consulta 1: 10 filas (una por cada venta, con todos los datos cruzados).
Consulta 2: 2 filas (los clientes nuevos sin compras).
Consulta 3: 1 fila (el único producto sin ventas).
Consulta 4: 2 filas (total facturado por Online y por Presencial).
