/*
================================================================================
Control de calidad
================================================================================
Proposito del script:
  Este script realiza control de calidad para validar la integridad,
  consistencia y presición de la capa 'Gold'. Estos controles garantizan:
    - Claves subrogadas unicas en las tablas de dimensión.
    - Integridad referencial entre las tablas de dimensiones y hechos.
    - Validación de relaciones en el modelo de datos para fines analíticos.
Notas para uso:
  - Ejecuta este script después de cargar los datos en la capa 'silver'.
  - Invertigar y resolver cualquier discrepancia encontrada durante el control.
================================================================================
*/

--===============================================================================
--Verificando 'gold.dim_customers'
--===============================================================================
--Verificando la singularidad de la columna customer_key en gold.dim_customers.
--Expectativas: Sin resultados.

SELECT 
	customer_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

--===============================================================================
--Verificando 'gold.dim_products'
--===============================================================================
--Verificando la singularidad de la columna customer_key en gold.dim_products.
--Expectativas: Sin resultados.

SELECT 
	product_key,
	COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

--===============================================================================
--Verificando 'gold.fact_sales'
--===============================================================================
--Verificando la conectividad del modelo de datos entre hechos y dimensiones.

SELECT 
*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS C
ON c.customer_key = f.customer_key 
LEFT JOIN gold.dim_products AS p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL or p.product_key IS NULL;
