/* 
===========================================================================================
Script DDL: Crear vistas para el esquema 'Gold'
===========================================================================================

Proposito del script:
  Este script crea vistas para la capa 'Gold' en el DataWareHouse.
  La capa 'Gold' representa las tablas finales de hechos y dimensiones (Start Schema).
  
  Cada vista representa transformaciones y combinaciones de datos desde la capa 'silver'
  para producir un conjunto de datos limpio, potenciado y listo para el negocio.

USO:
  -Estas vistas pueden ser consultadas directamente para análisis y reportes 
===========================================================================================
*/

--==================================================
--Creando la tabla de dimension: gold.dim_customers
--==================================================

DROP VIEW IF EXISTS gold.dim_customers;
CREATE OR REPLACE VIEW gold.dim_customers AS (
	SELECT
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		el.cntry AS country,
		ci.cst_marital_status AS marital_status,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM es la tabla maestra para informacion de genero
			 ELSE COALESCE(ec.gen, 'n/a')
		END AS gender,
		ci.cst_create_date AS create_date,
		ec.bdate AS birthday
	FROM silver.crm_cust_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ec
	ON ci.cst_key = ec.cid
	LEFT JOIN silver.erp_loc_a101 AS el
	ON ci.cst_key = el.cid
);

--==================================================
--Creando la tabla de dimension: gold.dim_products
--==================================================

DROP VIEW IF EXISTS gold.dim_products;
CREATE OR REPLACE VIEW gold.dim_products AS (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
		pi.prd_id AS product_id,
		pi.prd_key AS product_number,
		pi.prd_nm AS product_name,
		pi.cat_id AS category_id,
		ep.cat AS category,
		ep.subcat AS subcategory,
		ep.maintenance,
		pi.prd_cost AS cost,
		pi.prd_line AS product_line,
		pi.prd_start_dt AS start_date
	FROM silver.crm_prod_info AS pi
	LEFT JOIN silver.erp_px_cat_g1v2 AS ep
	ON pi.cat_id = ep.id 
	WHERE prd_end_dt IS NULL --Filtrando informacion por pedidos actuales que aun no tienen cierre 
);

--==================================================
--Creando la tabla de hechos: gold.fact_sales
--==================================================

DROP VIEW IF EXISTS gold.fact_sales;
CREATE VIEW gold.fact_sales AS (
	SELECT 
		sd.sls_ord_num AS order_number,
		pr.product_key,
		cu.customer_key,
		sd.sls_order_dt AS order_date,
		sd.sls_ship_dt AS shipping_date,
		sd.sls_due_dt AS due_date,
		sd.sls_sales AS sales_amount,
		sd.sls_quantity AS quantity,
		sd.sls_price AS price
	FROM silver.crm_sales_details AS sd
	LEFT JOIN gold.dim_products AS pr
	ON sd.sls_prd_key = pr.product_number
	LEFT JOIN gold.dim_customers AS cu
	ON sd.sls_cust_id = cu.customer_id
);
