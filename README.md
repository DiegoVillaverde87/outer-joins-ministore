# outer-joins-ministore

Práctica de LEFT JOIN, RIGHT JOIN y FULL OUTER JOIN para auditar el catálogo y las ventas de MiniStore.

## Archivos y ejecución

- `schema.sql`: crea las tablas y carga los 9 productos y las 10 ventas de la consigna.
- `soluciones.sql`: contiene las tres consultas y los filtros opcionales.
- `README.md`: explica las decisiones y los resultados.

En SQL Server Management Studio (SSMS), seleccioná tu base de prácticas y ejecutá primero `schema.sql`. Después ejecutá `soluciones.sql` en esa misma base. El esquema está preparado para SQL Server 2016 o posterior y se puede volver a ejecutar.

## Vistas completas y filtros de casos sin coincidencia

Las consultas principales conservan las vistas completas que pide la consigna. En cada consulta hay una línea `WHERE` comentada, antes del `ORDER BY`. Para aislar únicamente los casos de interés, quitá los dos guiones de esa línea y ejecutá esa consulta.

| Consulta | Vista completa | Con el WHERE opcional |
|---|---|---|
| LEFT JOIN | 11 filas que representan los 9 productos | 2 productos sin ventas: 108 y 109 |
| RIGHT JOIN | Las 10 ventas | 1 venta huérfana: venta 10, producto 999 |
| FULL OUTER JOIN | 12 filas de auditoría | 3 casos sin coincidencia |

Que haya 9 productos no significa que el LEFT JOIN deba devolver 9 filas. Los productos 101 y 102 tienen dos ventas cada uno, así que aparecen una vez por cada venta asociada.

## 1. ¿Por qué LEFT JOIN y no INNER JOIN en la Consulta 1?

Uso `productos` a la izquierda porque necesito conservar todo el catálogo, incluso cuando no existe una venta relacionada. El LEFT JOIN agrega las ventas que coinciden por `producto_id` y completa con NULL las columnas de ventas cuando no encuentra coincidencia.

Con INNER JOIN desaparecerían el producto 108, Hub USB-C 7p, y el 109, Parlante Bluetooth. Justamente son los productos que necesito detectar porque nunca se vendieron.

El filtro opcional `WHERE v.venta_id IS NULL` deja únicamente esos dos productos.

## 2. ¿Por qué RIGHT JOIN en la Consulta 2? ¿Qué tabla está de cada lado?

La consulta está escrita así:

```sql
FROM productos AS p
RIGHT JOIN ventas AS v
    ON p.producto_id = v.producto_id
```

`productos` está a la izquierda y `ventas` a la derecha. El RIGHT JOIN conserva todas las filas de la tabla de la derecha, por lo que la venta 10 aparece aunque su producto 999 no exista en el catálogo.

Un INNER JOIN ocultaría esa venta. El filtro opcional `WHERE p.producto_id IS NULL` permite mostrarla por separado.

## 3. ¿Qué representan los NULL en cada resultado?

En estos casos, los NULL en las claves primarias muestran que no hubo una fila coincidente en la otra tabla:

- **Consulta 1:** para los productos 108 y 109, `v.venta_id` es NULL porque no hay una venta asociada. Los productos sí existen y sus datos del catálogo se conservan.
- **Consulta 2:** en la venta 10, `p.producto_id` es NULL porque el producto vendido no aparece en el catálogo. En cambio, `v.producto_id` conserva el valor 999 que se registró en la venta.
- **Consulta 3:** aparecen ambos tipos de ausencia: productos con datos de ventas en NULL y ventas con datos del catálogo en NULL.

Por eso se muestran los dos identificadores con alias distintos: `producto_id_catalogo` y `producto_id_venta`. Así se puede distinguir el ID registrado en la transacción del que existe en el catálogo.

NULL no significa cero: en estos resultados señala la falta de coincidencia.

## 4. ¿Cuándo usaría FULL OUTER JOIN en un negocio real?

Lo usaría para conciliar un catálogo con un sistema de ventas, por ejemplo después de una migración o antes de preparar un dashboard. Necesito ver las coincidencias y también los registros que solo existen en uno de los sistemas.

En MiniStore, el FULL OUTER JOIN permite revisar en una sola salida los productos 108 y 109 sin ventas y la venta 10 con producto 999 sin catálogo. Un INNER JOIN ocultaría los tres casos.

La salida tiene 12 filas: 9 ventas con un producto coincidente, 2 productos sin ventas y 1 venta huérfana. Las coincidencias se combinan en una misma fila; por eso no se suman simplemente las 9 filas de productos y las 10 de ventas.

## Nota sobre los datos de prueba

`ventas.producto_id` no tiene una foreign key hacia `productos` en este esquema porque el ejercicio necesita conservar el producto inexistente 999 y detectarlo con los JOINs.

