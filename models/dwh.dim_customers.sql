---
Description: |
  Dimensión de clientes de Northwind. Una fila por cliente de staging.customers.
  Añade el área de ventas (continente) a partir del país. La carga es MERGE UPSERT:
  los clientes que desaparecen del origen no se borran.
Columns:
  customer_sid: Clave subrogada del cliente en el DWH.
  customer_id: Código del cliente en el origen (p. ej. ALFKI). Clave de negocio.
  customer: Nombre de la empresa cliente.
  contact_name: Persona de contacto.
  contact_title: Cargo de la persona de contacto.
  city: Ciudad del cliente.
  region: Región o estado del cliente. Vacío si no tiene.
  country: País del cliente.
  sales_area: "Área de ventas según el país: Europe, North America o South America."
---

CREATE OR REPLACE PROCEDURE
MERGE UPSERT dwh.dim_customers(customer_sid) KEY (customer_id)
SELECT
	customers.customer_id			customer_id nvarchar(5) NOT NULL,
	customers.company_name			customer,
	customers.contact_name			contact_name,
	customers.contact_title			contact_title,
	customers.city					city,
	customers.region				region,
	customers.country				country,
	CASE
		WHEN customers.country IN ('USA', 'Canada', 'Mexico') THEN 'North America'
		WHEN customers.country IN ('Argentina', 'Brazil', 'Venezuela') THEN 'South America'
		ELSE 'Europe'
	END								sales_area
FROM staging.customers
