---
Description: |
  Dimensión de clientes de AdventureWorks. Una fila por cliente (Customer) del ERP.
  Un cliente es una persona que compra online o una tienda (Store) que compra a través de un comercial.
  Incluye la dirección particular de la persona (tipo de dirección 2, Home), el territorio de ventas
  y los datos de la tienda (dirección de tipo 3, Main Office). La carga es MERGE UPSERT: los clientes
  que desaparecen del ERP no se borran.
Columns:
  customer_sid: Clave subrogada del cliente en el DWH.
  customer_id: Identificador del cliente en el ERP (Customer.CustomerID). Clave de negocio.
  customer: Nombre y apellidos de la persona del cliente.
  customer_type: "'Online' si el cliente no tiene tienda asociada; 'Store' si es una tienda."
  account_number: Número de cuenta del cliente en el ERP (p. ej. AW00011000).
  first_name: Nombre de la persona del cliente.
  middle_name: Segundo nombre o inicial de la persona del cliente.
  last_name: Apellidos de la persona del cliente.
  customer_address_country: País de la dirección particular (Home) de la persona del cliente.
  customer_province: Provincia o estado de la dirección particular (Home) de la persona del cliente.
  customer_territory: Territorio de ventas al que está asignado el cliente.
  customer_country: País del territorio de ventas del cliente. Puede no coincidir con customer_address_country.
  store: "Nombre de la tienda del cliente; 'Online' si el cliente no es una tienda."
  store_manager: Nombre y apellidos del comercial (SalesPerson) asignado a la tienda.
  store_country: País de la dirección principal (Main Office) de la tienda.
  store_province: Provincia o estado de la dirección principal (Main Office) de la tienda.
  store_city: Ciudad de la dirección principal (Main Office) de la tienda.
---

CREATE OR REPLACE PROCEDURE
MERGE UPSERT dwh.dim_customers(customer_sid)
MATERIALIZE
select
	Customer.CustomerId				#customer_id,
	concat(CustomerPerson.FirstName,' ',CustomerPerson.LastName)		customer,
	if(customer.StoreID IS NULL,'Online','Store')						customer_type,
	customer.AccountNumber			account_number,
	CustomerPerson.FirstName		first_name,
	CustomerPerson.MiddleName		middle_name,
	CustomerPerson.LastName			last_name,
	CustomerCountry.Name 			customer_address_country,
	CustomerProvince.Name 			customer_province,
	CustomerTerritory.Name			customer_territory,
	SalesCountry.Name 				customer_country,
	coalesce(Store.Name,'Online')	store,
	concat(StorePerson.FirstName,' ',StorePerson.LastName)		store_manager,
	StoreCountry.Name				store_country,
	StoreProvince.Name				store_province,
	StoreAddress.City				store_city,

from @@erp.customer
INNER JOIN @@erp.SalesTerritory CustomerTerritory using Customer(TerritoryId)
INNER JOIN @@erp.CountryRegion SalesCountry using CustomerTerritory(CountryRegionCode)
LEFT JOIN @@erp.Person CustomerPerson using Customer(PersonID BusinessEntityId)
LEFT JOIN @@erp.BusinessEntityAddress filter (AddressTypeid=2) using Customer(PersonID BusinessEntityId)
LEFT JOIN @@erp.Address CustomerAddress using BusinessEntityAddress(AddressId)
LEFT JOIN @@erp.StateProvince CustomerProvince using CustomerAddress(StateProvinceId)
LEFT JOIN @@erp.CountryRegion CustomerCountry using CustomerProvince(CountryRegionCode)
LEFT JOIN @@erp.Store using Customer(StoreId BusinessEntityId)
LEFT JOIN @@erp.BusinessEntityAddress filter (AddressTypeid=3) StoryBusinessEntityAddress using Store(BusinessEntityId)
LEFT JOIN @@erp.Address StoreAddress using StoryBusinessEntityAddress(AddressId)
LEFT JOIN @@erp.StateProvince StoreProvince using StoreAddress(StateProvinceId)
LEFT JOIN @@erp.CountryRegion StoreCountry using StoreProvince(CountryRegionCode)
LEFT JOIN @@erp.Person StorePerson using Store(SalesPersonID BusinessEntityId)
check snowflake
