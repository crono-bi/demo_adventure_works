
-- En este fichero deben escribirse las instrucciones para crear e inicializar la base
-- de datos, los esquemas u otros elementos que sean necesarios.


-- En este ejemplo se crea la base de datos con la misma intercalación que los datos de origen.
-- Esto habitualmente se hará directamente de SSMS	

CREATE DATABASE IF NOT EXISTS @@ConnectionDatabaseName COLLATE SQL_Latin1_General_CP1_CI_AS

-- Es importante establecer la intercalación correcta (por si se ha creado la BD fuera de Crono ETL)
ALTER DATABASE @@ConnectionDatabaseName COLLATE SQL_Latin1_General_CP1_CI_AS

-- Durante la inicialización se crea un servidor vinculado a una base de datos remota.
-- Habitualmente se crearía desde SSMS y no se incluiría el password en el proyecto.
CREATE LINKED SERVER IF NOT EXISTS [adventureworks.dwh.es] WITH (
	datasrc='adventureworks.dwh.es',
	provider='SQLOLEDB',
	catalog='AdventureWorks2016',
	rmtuser='AdventureWorks',
	rmtpassword='4KG1YViM3CYeOiQdVcscUzhTUa' 
)



CREATE SCHEMA IF NOT EXISTS audit
CREATE SCHEMA IF NOT EXISTS dwh
CREATE SCHEMA IF NOT EXISTS staging