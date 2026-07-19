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

Celeste Juárez - Coderhouse Data Analytics
