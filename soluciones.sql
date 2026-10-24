-- ══════════════════════════════════════════
-- MiniStore — Soluciones con Outer JOINs
-- Autor: Diego Villaverde
-- Fecha: 2026-10-24
-- Motor: SQL Server
-- ══════════════════════════════════════════

-- Ejecutar primero schema.sql en la misma base de datos.
-- Las consultas muestran las vistas completas solicitadas.
-- Cada una incluye un WHERE comentado: descomentarlo permite aislar los
-- registros sin coincidencia. El WHERE debe ir antes del ORDER BY.

-- ── CONSULTA 1: LEFT JOIN ─────────────────
-- Pregunta: ¿qué productos del catálogo nunca fueron vendidos?
-- Se conservan todos los productos, incluidos los que no tienen ventas.
-- Resultado completo: 11 filas, que representan los 9 productos.
-- Los productos 101 y 102 aparecen dos veces porque tienen dos ventas cada uno.
-- Los productos 108 y 109 tienen NULL en las columnas de ventas.
SELECT
    p.producto_id AS producto_id_catalogo,
    p.nombre AS nombre_producto,
    p.categoria,
    p.precio,
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta
FROM productos AS p
LEFT JOIN ventas AS v
    ON p.producto_id = v.producto_id
-- Para ver solo los 2 productos nunca vendidos, descomentar:
-- WHERE v.venta_id IS NULL
ORDER BY p.producto_id, v.venta_id;

-- ── CONSULTA 2: RIGHT JOIN ────────────────
-- Pregunta: ¿hay ventas con productos que no figuran en el catálogo?
-- productos está a la izquierda y ventas a la derecha.
-- Se conservan las 10 ventas, incluida la venta 10 con producto_id_venta = 999.
-- En esa venta, producto_id_catalogo y las demás columnas de productos son NULL.
SELECT
    p.producto_id AS producto_id_catalogo,
    p.nombre AS nombre_producto,
    p.categoria,
    p.precio,
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta
FROM productos AS p
RIGHT JOIN ventas AS v
    ON p.producto_id = v.producto_id
-- Para ver solo la venta huérfana, descomentar:
-- WHERE p.producto_id IS NULL
ORDER BY v.venta_id;

-- ── CONSULTA 3: FULL OUTER JOIN ───────────
-- Pregunta: ¿cómo ver todos los productos y todas las ventas para auditar?
-- Se incluyen coincidencias, productos sin ventas y ventas sin producto.
-- Resultado completo: 12 filas = 9 ventas con coincidencia + 2 productos
-- sin ventas + 1 venta sin producto en el catálogo.
SELECT
    p.producto_id AS producto_id_catalogo,
    p.nombre AS nombre_producto,
    p.categoria,
    p.precio,
    v.venta_id,
    v.producto_id AS producto_id_venta,
    v.cliente_id,
    v.cantidad,
    v.fecha_venta
FROM productos AS p
FULL OUTER JOIN ventas AS v
    ON p.producto_id = v.producto_id
-- Para ver solo los 3 casos sin coincidencia, descomentar:
-- WHERE p.producto_id IS NULL OR v.venta_id IS NULL
ORDER BY p.producto_id, v.venta_id;

