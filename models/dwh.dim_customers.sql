
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
