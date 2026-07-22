-- =====================================================================
-- m5_consultas_joins.sql
-- Modulo 5 - Cruzando tablas para enriquecer el analisis (JOINs)
-- Compatible con SQL SERVER (T-SQL)
-- =====================================================================
-- Nota: la consigna original asume un esquema con tabla "territorios"
-- y columnas "segmento" (clientes), "region" (clientes/territorios) y
-- "canal" (ventas), que no existian en la base creada en M3.
-- Esta primera seccion amplia el esquema para incorporarlos antes de
-- poder escribir las consultas pedidas.
-- =====================================================================

USE Ventas_Tech_DB;
GO

-- =====================================================================
-- SECCION 1: AMPLIACION DEL ESQUEMA
-- =====================================================================

-- 1.1) Tabla territorios (nueva)
IF OBJECT_ID('territorios', 'U') IS NOT NULL DROP TABLE territorios;
GO

CREATE TABLE territorios (
    id_territorio   INT PRIMARY KEY,
    nombre_region   VARCHAR(50) NOT NULL
);
GO

INSERT INTO territorios VALUES (1, 'AMBA');
INSERT INTO territorios VALUES (2, 'Centro');
INSERT INTO territorios VALUES (3, 'Litoral');
INSERT INTO territorios VALUES (4, 'Cuyo');
INSERT INTO territorios VALUES (5, 'NOA');
GO

-- 1.2) Columnas nuevas en clientes: segmento e id_territorio (FK)
IF COL_LENGTH('clientes', 'segmento') IS NULL
    ALTER TABLE clientes ADD segmento VARCHAR(20);
GO

IF COL_LENGTH('clientes', 'id_territorio') IS NULL
    ALTER TABLE clientes ADD id_territorio INT NULL
        CONSTRAINT FK_clientes_territorio REFERENCES territorios(id_territorio);
GO

-- 1.3) Columna nueva en ventas: canal
IF COL_LENGTH('ventas', 'canal') IS NULL
    ALTER TABLE ventas ADD canal VARCHAR(20);
GO

-- 1.4) Completar segmento y territorio para los clientes existentes (M3)
UPDATE clientes SET segmento = 'Premium',  id_territorio = 1 WHERE id_cliente = 1; -- Buenos Aires
UPDATE clientes SET segmento = 'Standard', id_territorio = 2 WHERE id_cliente = 2; -- Cordoba
UPDATE clientes SET segmento = 'Premium',  id_territorio = 3 WHERE id_cliente = 3; -- Rosario
UPDATE clientes SET segmento = 'Standard', id_territorio = 4 WHERE id_cliente = 4; -- Mendoza
UPDATE clientes SET segmento = 'Standard', id_territorio = 5 WHERE id_cliente = 5; -- Tucuman
GO

-- 1.5) Nuevos clientes SIN ventas, para poder demostrar la Consulta 2
-- Nota: se especifican las columnas explicitamente porque la tabla
-- clientes ya tiene 7 columnas (se agregaron segmento e id_territorio
-- en el paso 1.2), y aca solo cargamos los datos originales de M3.
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (6, 'Jorge Medina', 'jorge@mail.com', 'La Plata', '2024-04-01');
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (7, 'Sofia Paz',    'sofia@mail.com', 'Salta',    '2024-04-10');
UPDATE clientes SET segmento = 'Standard', id_territorio = 1 WHERE id_cliente = 6; -- La Plata -> AMBA
UPDATE clientes SET segmento = 'Standard', id_territorio = 5 WHERE id_cliente = 7; -- Salta -> NOA
GO

-- 1.6) Completar canal para las 10 ventas existentes (M3/M4)
-- Nota: el producto 5 (SSD Externo 1TB) no tiene ninguna venta cargada,
-- por lo que va a aparecer como resultado en la Consulta 3.
UPDATE ventas SET canal = 'Online'      WHERE id_venta IN (1, 3, 5, 7, 9);
UPDATE ventas SET canal = 'Presencial'  WHERE id_venta IN (2, 4, 6, 8, 10);
GO

-- =====================================================================
-- SECCION 2: CONSULTAS CON JOINs
-- =====================================================================

-- =====================================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Union de ventas + clientes + productos + categorias + territorios.
-- Esta es la fuente principal para el dashboard de Power BI (M7).
-- =====================================================================
SELECT
    v.fecha_venta,
    c.nombre                           AS nombre_cliente,
    c.segmento,
    t.nombre_region                    AS region,
    p.nombre_producto,
    cat.nombre_categoria               AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario)   AS total_venta,
    v.canal
FROM ventas v
INNER JOIN clientes c    ON v.id_cliente = c.id_cliente
INNER JOIN productos p   ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
INNER JOIN territorios t ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;
GO

-- =====================================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que todavia no realizaron ninguna compra.
-- =====================================================================
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
GO

-- =====================================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Productos del catalogo que no tienen ninguna venta registrada.
-- =====================================================================
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
GO

-- =====================================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- Combina ventas Online y Presencial en un solo resultado, y calcula
-- el total facturado por canal.
-- =====================================================================
WITH ventas_por_canal AS (
    SELECT id_venta, cantidad, precio_unitario, 'Online' AS canal
    FROM ventas
    WHERE canal = 'Online'

    UNION ALL

    SELECT id_venta, cantidad, precio_unitario, 'Presencial' AS canal
    FROM ventas
    WHERE canal = 'Presencial'
)
SELECT
    canal,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas_por_canal
GROUP BY canal
ORDER BY canal;
GO
