/* 
=============================================================================
Procedimiento almacenado: Cargar la capa 'bronze' (source -> bronze)
=============================================================================
Proposito del Script: 
  Este procedimiento almacenado carga los datos dentro del esquema 'bronze'
  extrayendolos de archivos con extensión CSV.
  El script ejecuta las siguientes acciones:
    -Vacia las tablas de la capa 'bronze' (TRUNCATES) antes de cargar los 
    datos.
    -Usa el comando nativo COPY para cargar los datos de los archivos CSV a 
    las tablas del esquema 'bronze'
Parametros:
  Ninguno.
  Este procedimiento almacemado no acepta parametros ni retorna ningún valor.
Ejemplo de uso:
  CALL bronze.load_bronze();
=============================================================================
*/



CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
	RAISE NOTICE 'Loadindg Bronze Layer';
	RAISE NOTICE '====================================';

	RAISE NOTICE '------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '------------------------------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;

	RAISE NOTICE E'>>Inserting Data Into: bronze.crm_cust_info\n';
	COPY bronze.crm_cust_info
	FROM '/tmp/source_crm/cust_info.csv' --Ruta donde se almacenan los datos 
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.crm_prod_info';
	TRUNCATE TABLE bronze.crm_prod_info;
	
	RAISE NOTICE E'>>Inserting Data Into:  bronze.crm_prod_info\n';
	COPY bronze.crm_prod_info
	FROM '/tmp/source_crm/prd_info.csv'
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	
	RAISE NOTICE E'>>Inserting Data Into: bronze.crm_sales_details\n';
	COPY bronze.crm_sales_details
	FROM '/tmp/source_crm/sales_details.csv'
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';
	
	RAISE NOTICE '------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '------------------------------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;
	
	RAISE NOTICE E'>>Inserting Data Into: bronze.erp_cust_az12\n';
	COPY bronze.erp_cust_az12
	FROM '/tmp/source_erp/CUST_AZ12.csv'
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101;
	
	RAISE NOTICE E'>>Inserting Data Into: bronze.erp_loc_a101\n';
	COPY bronze.erp_loc_a101
	FROM '/tmp/source_erp/LOC_A101.csv'
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';

	start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>>Truncating Table: bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	RAISE NOTICE E'>>Inserting Data Into: bronze.erp_px_cat_g1v2\n';
	COPY bronze.erp_px_cat_g1v2
	FROM '/tmp/source_erp/PX_CAT_G1V2.csv'
	WITH DELIMITER ',' CSV HEADER;
	end_time := CLOCK_TIMESTAMP();
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM end_time - start_time) AS VARCHAR), ' ','seconds');
	RAISE NOTICE '>>Load Duration: %', execution_time;
	RAISE NOTICE '>>-------------';
	batch_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '======================================';
	RAISE NOTICE 'Loading bronze layer is completed';
	execution_time := CONCAT(CAST(EXTRACT(EPOCH FROM batch_end_time - batch_start_time) AS VARCHAR), ' ', 'seconds');
	RAISE NOTICE '- Total Load Duration: %', execution_time;
	RAISE NOTICE '======================================';
	
	EXCEPTION 
		WHEN OTHERS THEN
			RAISE NOTICE 'An Error Occurred: %', SQLERRM;	
END;
$$
LANGUAGE plpgsql;

CALL bronze.load_bronze(); --Llamada al procedimiento almacenado
