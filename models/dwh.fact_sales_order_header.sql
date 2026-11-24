

CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.fact_sales_order_header(sales_order_sid)
SELECT
	SalesOrderHeader.SalesOrderId				#sales_order_id,
	dim_customers.customer_sid					customer_sid		REFERENCES dwh.dim_customers,
	cast(SalesOrderHeader.OrderDate as date) 	order_date			REFERENCES dwh.dim_dates([date]),
	SalesOrderHeader.SalesOrderNumber			sales_order_number,
	cast(SalesOrderHeader.DueDate as date)		due_date			REFERENCES dwh.dim_dates([date]),
	cast(SalesOrderHeader.ShipDate as date) 	ship_date			REFERENCES dwh.dim_dates([date]),
	SalesOrderHeader.OnlineOrderFlag			online_order_flag,
	SalesOrderHeader.PurchaseOrderNumber		purchase_order_number,
	SalesOrderHeader.AccountNumber				account_number,
	SalesOrderHeader.Freight					freight,
	SalesOrderHeader.CreditCardApprovalCode		credit_card_approval_code,
	ShipMethod.Name								shipping_method,
	concat(SalesPersonPerson.FirstName,' ',SalesPersonPerson.LastName) sales_person,
	Currency.Name								original_currency,
	BillToCountry.Name							bill_country,
	BillToProvince.Name							bill_province,
	BillToAddress.City							bill_city,
	BillToAddress.AddressLine1					bill_address_line1,
	BillToAddress.AddressLine2					bill_address_line2,
	BillToAddress.PostalCode					bill_postal_code,
	ShipToCountry.Name							ship_country,
	ShipToProvince.Name							ship_province,
	ShipToAddress.City							ship_city,
	ShipToAddress.AddressLine1					ship_address_line1,
	ShipToAddress.AddressLine2					ship_address_line2,
	ShipToAddress.PostalCode					ship_postal_code,
	concat(CreditCardPerson.FirstName,' ',CreditCardPerson.LastName) credit_card_person,
	CreditCard.CardType							card_type,
	CreditCard.CardNumber						card_number,
	SalesOrderHeader.TaxAmt						tax_amt
FROM @@erp.SalesOrderHeader materialize SalesOrderHeader
REMOTE LEFT JOIN @@erp.Employee using SalesOrderHeader(SalesPersonId BusinessEntityId)
REMOTE INNER JOIN @@erp.Address BillToAddress using SalesOrderHeader(BilltoAddressID AddressId)
REMOTE INNER JOIN @@erp.StateProvince BillToProvince using BillToAddress(StateProvinceId)
REMOTE INNER JOIN @@erp.CountryRegion BillToCountry using BillToProvince(CountryRegionCode)
REMOTE INNER JOIN @@erp.Address ShipToAddress using SalesOrderHeader(ShiptoAddressID AddressId)
REMOTE INNER JOIN @@erp.StateProvince ShipToProvince using ShipToAddress(StateProvinceId)
REMOTE INNER JOIN @@erp.CountryRegion ShipToCountry using ShipToProvince(CountryRegionCode)
REMOTE INNER JOIN @@erp.ShipMethod using SalesOrderHeader(ShipMethodId)
REMOTE LEFT JOIN @@erp.person SalesPersonPerson using SalesOrderHeader(SalesPersonID BusinessEntityID)
REMOTE LEFT JOIN @@erp.CurrencyRate using SalesOrderHeader(currencyRateID)
REMOTE LEFT JOIN @@erp.Currency using CurrencyRate(ToCurrencycode CurrencyCode )
REMOTE LEFT JOIN @@erp.CreditCard using SalesOrderHeader(CreditCardId)
REMOTE LEFT JOIN @@erp.PersonCreditCard using CreditCard(CreditCardId)
REMOTE LEFT JOIN @@erp.person CreditCardPerson using PersonCreditCard(BusinessEntityID BusinessEntityID)
REMOTE INNER JOIN @@erp.customer using SalesOrderHeader(customerId)
INNER JOIN dwh.dim_customers using Customer(CustomerId customer_id)
check snowflake
