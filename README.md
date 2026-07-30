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



## Módulo 5 - Consultas con JOINs (`m5_consultas_joins.sql`)

Las consultas de M4 trabajaban sobre tablas individuales. En este módulo se cruzan para obtener una vista enriquecida (ventas + cliente + producto + categoría + región), que es la fuente de datos principal para el dashboard de Power BI (M7).

### Ampliación del esquema

La consigna de M5 requería campos que la base original (M3) no tenía todavía, así que este script primero amplía el esquema antes de las consultas:

- **Tabla nueva `territorios`**: `id_territorio`, `nombre_region` (AMBA, Centro, Litoral, Cuyo, NOA).
- **`clientes`**: se agregan las columnas `segmento` (Premium / Standard) e `id_territorio` (FK a `territorios`).
- **`ventas`**: se agrega la columna `canal` (Online / Presencial).
- Se completan estos datos para los clientes y ventas ya cargados en M3.
- Se agregan 2 clientes nuevos sin compras (Jorge Medina, Sofía Paz), para poder demostrar la Consulta 2 con resultados reales.

### Las 4 consultas

1. **Vista base del proyecto (INNER JOIN)**: combina `ventas`, `clientes`, `productos`, `categorias` y `territorios` en una sola fila por venta — fecha, cliente, segmento, región, producto, categoría, cantidad, precio, total y canal.
2. **Clientes sin ventas (LEFT JOIN)**: clientes registrados que todavía no compraron nada, usando `WHERE ... IS NULL`.
3. **Productos sin ventas (LEFT JOIN)**: productos del catálogo sin ninguna venta registrada. En los datos actuales, el único caso es el SSD Externo 1TB.
4. **Consolidado por canal (UNION ALL)**: combina las ventas Online y Presencial en un solo resultado y calcula el total facturado por canal con `GROUP BY`.

### Cómo ejecutarlo

Requiere haber corrido antes `ventas_tech_db.sql` (M3), ya que amplía esa misma base de datos.

1. Abrí `m5_consultas_joins.sql` directamente en SSMS.
2. Ejecutá el script completo (F5). Primero corre la ampliación de esquema y después las 4 consultas, mostrando sus resultados en orden.

### Resultados esperados

- Consulta 1: 10 filas (una por cada venta, con todos los datos cruzados).
- Consulta 2: 2 filas (los clientes nuevos sin compras).
- Consulta 3: 1 fila (el único producto sin ventas).
- Consulta 4: 2 filas (total facturado por Online y por Presencial).

---

## Módulo 6 - Pipeline ETL con Power Query y lenguaje M (`Pipeline_ETL_Juarez_Celeste.pbix`)

### Contexto y fuente de datos

Se utilizó el dataset provisto por la cátedra: `Pipeline_ETL_Dataset.xlsx`, con 4 hojas (`clientes`, `productos`, `ventas`, `categorias`) que contienen problemas de calidad intencionales: registros duplicados por clave primaria, valores nulos en campos críticos y filas vacías de más en el rango de datos de Excel.

### 1. Conexión y perfilado

Se conectó Power BI Desktop al archivo mediante el conector de Excel (`Obtener datos → Excel`), seleccionando las 4 tablas requeridas y entrando directamente a **Transformar datos** para trabajar en Power Query antes de confirmar la carga.

### 2. Problema detectado en las 3 tablas: filas vacías "fantasma"

Además de los duplicados y nulos ya previstos por la consigna, se encontró que las hojas de Excel traían un rango de datos más amplio del necesario, generando filas completamente vacías al final de cada tabla (por ejemplo, `Fact_Ventas` mostraba 999 filas en vez de las 50 reales). Se resolvieron filtrando por la columna de ID de cada tabla (`Table.SelectRows(..., each [id_X] <> null)`), antes de aplicar cualquier otra transformación.

### 3. Transformaciones por tabla

**Dim_Clientes** (12 filas originales → 11 finales)
- Se eliminó el registro duplicado (`id_cliente = 1`, María López) con `Table.Distinct` sobre la clave primaria.
- **Email nulo** (`id_cliente = 9`, Valentina Paz): esta clienta tiene **5 ventas registradas** en `Fact_Ventas`. Eliminar la fila implicaría perder esas transacciones del análisis, así que se reemplazó el nulo por `"sin_email@pendiente.com"`, dejando explícito que el dato queda pendiente de completar.
- **Ciudad nula** (`id_cliente = 11`, Roberto Díaz): sin ventas todavía, pero es un cliente válido y activo. Se conservó el registro y se reemplazó el nulo por `"sin especificar"`.

**Dim_Productos** (13 filas originales → 12 finales)
- Se eliminó el producto duplicado (`id_producto = 103`, Monitor 4K 27") con `Table.Distinct` sobre la clave primaria.
- **Precio nulo** (`id_producto = 109`, SSD Externo 1TB): este producto tiene **5 ventas registradas**, y en todas ellas se vendió históricamente a **$130**. En vez de inventar un valor arbitrario, se usó ese precio real ya validado por el histórico de transacciones.
- **Categoría nula** (`id_producto = 111`, Laptop Gaming Pro): su `subcategoria` ("Laptops") coincide con la de otros productos de la categoría "Computación". Se infirió la categoría por esa relación lógica, en vez de asignar un genérico "Sin Categoría".

**Dim_Categorias** (4 filas)
- Tabla sin problemas de calidad; solo se corrigieron tipos de datos.

**Fact_Ventas** (50 filas)
- Se corrigió el tipo de la columna `fecha_venta`, que Power Query detectaba automáticamente como número entero (número de serie de Excel) en vez de fecha.
- Se aplicó un **Merge** con `Dim_Productos` (combinación externa izquierda, uniendo por `id_producto`), expandiendo únicamente las columnas `nombre_producto` y `categoria`. El emparejamiento fue exacto: 50 de 50 filas encontraron su producto correspondiente.

### 4. Nomenclatura profesional

Las 4 consultas se renombraron siguiendo el estándar del área: `Dim_Clientes`, `Dim_Productos`, `Dim_Categorias`, `Fact_Ventas`.

### 5. Documentación en lenguaje M

Se agregaron comentarios técnicos (`//`) directamente en el Editor Avanzado de `Dim_Clientes` y `Dim_Productos`, explicando el razonamiento de cada decisión (por qué se eliminó cada duplicado, por qué se conservó cada fila con nulo y con qué criterio se reemplazó cada valor), no solo qué paso se ejecutó.

### 6. Verificación final

Al cerrar y aplicar, las 4 tablas cargaron sin errores, con el conteo de filas esperado:

| Tabla | Filas |
|---|---|
| Dim_Clientes | 11 |
| Dim_Productos | 12 |
| Dim_Categorias | 4 |
| Fact_Ventas | 50 |
