/*
=============================================================
Crear la base de datos y esquemas
=============================================================
Proposito del script: 
    Este script crea una nueva base de datos llamada 'DataWarehouse' luego de checar si ya existe. 
    Si la base de datos existe, es eliminada y recreada. Adicionalmente, El script establece tres esquemas
    dentro de la base de datos: 'bronze', 'silver', and 'gold'.
*/

--Borrar y recrear la base de datos DataWareHouse
DROP DATABASE IF EXISTS datawarehouse WITH(FORCE);

--Creación de la base de datos
CREATE DATABASE DataWareHouse;

--Creación de los esquemas 
CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;
