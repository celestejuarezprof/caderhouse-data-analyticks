-- =====================================================================
-- m4_consultas_negocio.sql
-- Modulo 4 - Consultas SQL de negocio sobre Ventas_Tech_DB
-- Compatible con SQL SERVER (T-SQL)
-- =====================================================================
-- Nota de compatibilidad: la consigna sugiere usar
-- EXTRACT(MONTH FROM fecha_venta), que es sintaxis de PostgreSQL.
-- En SQL Server el equivalente es MONTH(fecha_venta), que es lo que
-- se usa en este archivo.

USE Ventas_Tech_DB;
GO

-- =====================================================================
-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, por mes.
-- =====================================================================
SELECT
    MONTH(fecha_venta)                     AS mes,
    SUM(cantidad * precio_unitario)        AS total_facturado,
    COUNT(*)                               AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)        AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
GO

-- =====================================================================
-- Consulta 2: Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades vendidas.
-- =====================================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                          AS unidades_vendidas,
    SUM(cantidad * precio_unitario)        AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
GO

-- =====================================================================
-- Consulta 3: Clientes recurrentes
-- id_cliente con mas de un pedido, con cantidad de pedidos y gasto total.
-- =====================================================================
SELECT
    id_cliente,
    COUNT(*)                               AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)        AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
GO

-- =====================================================================
-- Consulta 4: Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado contra el promedio mensual general.
-- =====================================================================
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)                 AS mes,
        SUM(cantidad * precio_unitario)    AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;
GO

-- =====================================================================
-- Hallazgos
-- =====================================================================
-- 1. El producto 1 concentra el 55.9% de la facturacion total
--    ($3.600 de $6.444), muy por encima del resto: el segundo puesto
--    (producto 3) representa apenas el 21% ($1.350). Es el producto
--    que mas impacto tiene en el negocio.
--
-- 2. Los 5 clientes cargados son "recurrentes" (2 pedidos cada uno),
--    pero con gasto muy desparejo: el cliente 1 gasto $2.640 en sus
--    dos compras, mientras que el cliente 4 gasto solo $510. Tener
--    mas de un pedido no implica ser un cliente de alto valor.
--
-- 3. Las 10 ventas cargadas caen todas dentro de marzo de 2024
--    (05/03 al 15/03), asi que la Consulta 1 y la Consulta 4 devuelven
--    un unico mes. La comparacion "por encima/por debajo del promedio"
--    no es representativa todavia: para un analisis de estacionalidad
--    real hace falta cargar ventas de varios meses distintos.
