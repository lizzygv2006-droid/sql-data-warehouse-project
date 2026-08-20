/* 
========================================================================================
Verificación de calidad 
========================================================================================
Proposito del script:
  Este script realiza varias verificaciones de calidad de consistencia, precisión
  y estandarización de datos a través del esquema 'silver'. 
Eso incluye verificaciones para:
  -Claves primarias nulas o duplicadas.
  -Espacios en blanco indeseados en datos tipo string.
  -Estandarización y consistencia de datos. 
  -Orden y rangos de fecha inválidos.
  -Consistencia de datos entre campos relacionados.
Uso de notas 
  -Ejecuta este script después de la carga de datos de las tablas del esquema 'silver'.
  -Investigar y resolver cualquier discrepancia encontrada durante la verificación.
=======================================================================================
*/


--==================================
--Verificando 'silver.crm_cust_info'
--==================================
--Revisando por valores nulos o duplicados en llave primaria 
SELECT 
	cst_id,
	COUNT(*) AS TOTAL
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

--Verificación de espacios en blanco indeseados
--Expectativa: No resultados
SELECT 
	cst_key
FROM silver.crm_cust_info 
WHERE cst_key != TRIM(cst_key);

--Estandarización y consistencia de datos
SELECT DISTINCT
	cst_marital_status
FROM silver.crm_cust_info;

--==================================
--Verificando 'silver.crm_prod_info'
--==================================
--Revisando por valores nulos o duplicados en llave primaria 
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prod_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
---Verificación de espacios en blanco indeseados
--Expectativa: No resultados
SELECT
	prd_nm 
FROM silver.crm_prod_info
WHERE prd_nm != TRIM(prd_nm);

--Verificación de valores nulos o negativos en costo
--Expectativa: No resultados
SELECT 
	prd_cost
FROM silver.crm_prod_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

--Estandarización y consistencia de datos
SELECT DISTINCT
	prd_line 
FROM silver.crm_prod_info;

--Verificación de fechas invalidas de pedidos (fecha de inicio > fecha de cierre)
--Expectativa: No resultados
SELECT 
	*
FROM silver.crm_prod_info
WHERE prd_start_dt > prd_end_dt;

--======================================
--Verificando 'silver.crm_sales_details'
--======================================

--Verificación de fechas invalidas antes de la inserción a la tabla silver.crm_sales_details
--Expectativa: No resultados
SELECT 
	COALESCE(sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details 
WHERE sls_due_dt <= 0
OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101;

--Verificación de fechas invalidas de pedidos (fecha de pedido > fecha de salida y fecha limite)
--Expectativa: No resultados
SELECT 
	*
FROM silver.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt;

-- Verificación de consistencia de datos: Ventas = cantidad * precio
--Expectativa: No resultados
SELECT 
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales <= 0
OR sls_quantity <= 0
OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

--==================================
--Verificando 'silver.erp_cust_az12'
--==================================

--Identificando fechas fuera de rango 
--Expectativa: Fechas menores al dia actual 
SELECT DISTINCT 
	bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_TIMESTAMP;

--Identificando fechas de nacimiento invalidas (Fechas superiores a la actual)
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_TIMESTAMP
ORDER BY bdate DESC;

--Estandarización y consistencia de datos
SELECT DISTINCT 
gen
FROM silver.erp_cust_az12;

--==================================
--Verificando 'silver.erp_loc_a101'
--==================================

--Estandarización y consistencia de datos
SELECT DISTINCT 
	cntry
FROM silver.erp_loc_a101;

--==================================
--Verificando 'silver.erp_loc_a101'
--==================================

--Verificación de espacios en blanco indeseados
SELECT 
	*
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance);

--Estandarización y consistencia de datos
SELECT DISTINCT
	maintenance 
FROM silver.erp_px_cat_g1v2;
