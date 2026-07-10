USE Ventas_Tech_DB;
GO

-- =====================================================================
-- 1) DROP TABLES
--    Orden inverso a las dependencias: primero la tabla de hechos
--    (ventas), despues las tablas que ella referencia (productos,
--    clientes) y al final la que no depende de nadie (categorias).
-- =====================================================================
IF OBJECT_ID('ventas', 'U') IS NOT NULL DROP TABLE ventas;
IF OBJECT_ID('productos', 'U') IS NOT NULL DROP TABLE productos;
IF OBJECT_ID('clientes', 'U') IS NOT NULL DROP TABLE clientes;
IF OBJECT_ID('categorias', 'U') IS NOT NULL DROP TABLE categorias;
GO

-- =====================================================================
-- 2) CREATE TABLES (DDL) + RESTRICCIONES DE INTEGRIDAD
--    Orden: primero las tablas de dimension, al final la tabla de
--    hechos, para que las FOREIGN KEY siempre encuentren su referencia.
-- =====================================================================

-- Tabla categorias -------------------------------------------------
CREATE TABLE categorias (
    id_categoria       INT PRIMARY KEY,
    nombre_categoria   VARCHAR(50)  NOT NULL,
    descripcion        VARCHAR(200)
);

-- Tabla clientes -----------------------------------------------------
CREATE TABLE clientes (
    id_cliente      INT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE NOT NULL
);

-- Tabla productos ------------------------------------------------------
-- La categoria vive en su propia tabla (no como texto suelto) para
-- cumplir con 3NF: evita repetir "Computacion", "Accesorios", etc.
-- en cada fila de producto.
-- Nota: SQL Server no tiene tipo BOOLEAN -> se usa BIT (0/1).
CREATE TABLE productos (
    id_producto      INT PRIMARY KEY,
    nombre_producto  VARCHAR(100)   NOT NULL,
    id_categoria     INT            NOT NULL REFERENCES categorias(id_categoria),
    precio           DECIMAL(10,2)  NOT NULL,
    stock            INT            DEFAULT 0,
    activo           BIT            DEFAULT 1
);

-- Tabla ventas (tabla de hechos) --------------------------------------
-- Conecta clientes y productos. Las FOREIGN KEY garantizan que no se
-- pueda registrar una venta de un cliente o producto inexistente.
CREATE TABLE ventas (
    id_venta         INT PRIMARY KEY,
    id_cliente       INT            NOT NULL REFERENCES clientes(id_cliente),
    id_producto      INT            NOT NULL REFERENCES productos(id_producto),
    cantidad         INT            NOT NULL,
    precio_unitario  DECIMAL(10,2)  NOT NULL,
    fecha_venta      DATE           NOT NULL
);
GO

-- =====================================================================
-- 3) INSERT DATA (DML) - Carga inicial
--    Orden: primero las tablas sin dependencias (categorias, clientes),
--    despues productos (depende de categorias), y al final ventas
--    (depende de clientes y productos).
-- =====================================================================

-- categorias: 4 registros ---------------------------------------------
INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
    (1, 'Computación',     'Laptops, PCs y monitores'),
    (2, 'Accesorios',      'Periféricos y complementos'),
    (3, 'Audio',           'Auriculares y parlantes'),
    (4, 'Almacenamiento',  'Discos y memorias');

-- clientes: 5 registros -------------------------------------------------
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
    (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
    (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
    (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
    (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
    (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

-- productos: 6 registros -------------------------------------------------
-- Nota: BIT usa 1/0 en lugar de TRUE/FALSE.
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
    (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
    (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
    (3, 'Monitor 4K 27"',     1,  450.00, 12, 1),
    (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
    (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
    (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

-- ventas: 10 registros ----------------------------------------------------
INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
    (1,  1, 1, 2, 1200.00, '2024-03-05'),
    (2,  2, 2, 5,   28.00, '2024-03-06'),
    (3,  3, 3, 1,  450.00, '2024-03-07'),
    (4,  1, 4, 2,  120.00, '2024-03-08'),
    (5,  4, 5, 3,  130.00, '2024-03-10'),
    (6,  2, 6, 4,   95.00, '2024-03-11'),
    (7,  5, 1, 1, 1200.00, '2024-03-12'),
    (8,  3, 2, 8,   28.00, '2024-03-13'),
    (9,  4, 4, 1,  120.00, '2024-03-14'),
    (10, 5, 3, 2,  450.00, '2024-03-15');
GO

-- =====================================================================
-- 4) VALIDACIÓN
--    Confirmar que las 4 tablas se cargaron correctamente.
-- =====================================================================
SELECT * FROM categorias;
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
GO
