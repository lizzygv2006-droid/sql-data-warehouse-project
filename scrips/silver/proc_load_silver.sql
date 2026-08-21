/* 
=========================================================================================
Procedimiento almacenado: Cargar las tablas del esquema 'silver' (Bronze --> Silver) 
=========================================================================================
Proposito del script:
  Este procedimiento almacenado realiza el proceso ETL (Extract, Transform, Load) para 
  ingresar datos a las tablas del esquema 'silver' desde el esquema 'bronze'
Acciones realizadas:
  -Vacia las tablas del esquema 'silver' (Truncating)
  -Ingresa datos transformados y limpios desde las tablas del esquema 'bronze' hasta las
  tablas del esquema 'silver'.
Parametros:
  -Ninguno
  Este procedimiento almacenado no acepta ningún parametro ni retorna ningún valor.
Ejemplo de uso:  
  CALL silver.load_silver();
=========================================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver ()
AS $$
DECLARE 
		start_time TIMESTAMPTZ;
		end_time TIMESTAMPTZ;
		execution_time VARCHAR;
		batch_start_time TIMESTAMPTZ;
		batch_end_time TIMESTAMPTZ;
BEGIN
	batch_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '====================================';
	RAISE NOTICE 'Loadindg Silver Layer';
	RAISE NOTICE '====================================';

	RAISE NOTICE '------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE E'------------------------------------\n';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;
	RAISE NOTICE '>>Inserting data into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
	
	SELECT 
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname, 
		TRIM(cst_lastname) AS cst_lastname,
		CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a' --normalizar valores de estado civil a un formato más amistoso con el usuario
		END cst_marital_status,
		CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr, --normalizar valores de genero a un formato más amistoso con el usuario
		cst_create_date
	FROM (
		SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
	)t
	WHERE flag_last = 1; --Seleccionar el registro más reciente del cliente
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.crm_prod_info';
	TRUNCATE TABLE silver.crm_prod_info;
	RAISE NOTICE '>>Inserting data into: silver.crm_prod_info';
	INSERT INTO silver.crm_prod_info (
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS category_id, -- extrayendo category_id 
		SUBSTRING(prd_key, 7, LENGTH(prd_key)) as prd_key, --extrayendo clave del producto
		prd_nm,
		COALESCE(prd_cost, 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line)) 
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'other sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END prd_line, --Mapeando linea de producto con valores mas amistosos con el usuario
		prd_start_dt,
		LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS  prd_end_dt --Calcular fecha final un dia antes del siguiente comienzo de fecha 
	FROM bronze.crm_prod_info;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	RAISE NOTICE '>>Inserting data into: silver.crm_sales_details';
	INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt, 
	sls_due_dt, 
	sls_sales, 
	sls_quantity,
	sls_price
	)
	SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE 
			WHEN  sls_ship_dt = 0 OR LENGTH(CAST( sls_ship_dt AS VARCHAR)) != 8 THEN NULL
			ELSE CAST(CAST( sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE 
			WHEN  sls_due_dt = 0 OR LENGTH(CAST( sls_due_dt AS VARCHAR)) != 8 THEN NULL
			ELSE CAST(CAST( sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE 
			WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity,
		CASE 
			WHEN sls_price IS NULL OR sls_price <= 0
			THEN sls_sales / (CASE WHEN sls_quantity = 0 THEN NULL ELSE sls_quantity END)
			ELSE sls_price
		END AS sls_price
	FROM bronze.crm_sales_details;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';
	
	RAISE NOTICE '------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE E'------------------------------------\n';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	RAISE NOTICE '>>Inserting data into: silver.erp_cust_az12';
	INSERT INTO silver.erp_cust_az12 (
	cid,
	bdate,
	gen
	)
	
	SELECT 
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
			 ELSE cid
		END  AS cid,
		CASE 
			WHEN bdate > CURRENT_TIMESTAMP THEN NULL
			ELSE bdate
		END AS bdate,
		CASE 
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'n/a'
		END  AS gen
	FROM bronze.erp_cust_az12;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	RAISE NOTICE '>>Inserting data into: silver.erp_loc_a101';
	INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
	)
	SELECT 
		REPLACE(cid,'-', '') AS cid,
		CASE 
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
			WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry --Normalizar y tratar con valores faltantes en la columna cntry 
	FROM bronze.erp_loc_a101;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';
	
	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	RAISE NOTICE '>>Inserting data into: silver.erp_px_cat_g1v2';
	INSERT INTO silver.erp_px_cat_g1v2 (
	id, 
	cat,
	subcat,
	maintenance
	)
	SELECT
		id,
		cat,
		subcat,
		maintenance
	FROM bronze.erp_px_cat_g1v2;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE E'>>-------------\n';
	
	batch_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '======================================';
	RAISE NOTICE 'Loading silver layer is completed';
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM batch_end_time - batch_start_time) AS VARCHAR), ' ', 'seconds');
	RAISE NOTICE '- Total Load Duration: %', execution_time;
	RAISE NOTICE '======================================';

	EXCEPTION 
		WHEN OTHERS THEN
			RAISE NOTICE 'An Error Occurred: %', SQLERRM;	
END;
$$
LANGUAGE plpgsql;
