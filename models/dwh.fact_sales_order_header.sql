---
Description: |
  Hechos de cabeceras de pedidos de venta de AdventureWorks. Una fila por pedido
  (SalesOrderHeader) del ERP, con su cliente, sus fechas, el envío, la facturación,
  el comercial, la divisa y la tarjeta de crédito. Las líneas de cada pedido están en
  dwh.fact_sales_order_details. Los importes están en USD.
Columns:
  sales_order_sid: Clave subrogada del pedido en el DWH.
  sales_order_id: Identificador del pedido en el ERP (SalesOrderHeader.SalesOrderID). Clave de negocio.
  customer_sid: Cliente que hace el pedido. Referencia a dwh.dim_customers.
  order_date: Fecha del pedido. Referencia a dwh.dim_dates.
  sales_order_number: Número del pedido (p. ej. SO43659).
  due_date: Fecha en la que el cliente debe recibir el pedido. Referencia a dwh.dim_dates.
  ship_date: Fecha de envío del pedido. Referencia a dwh.dim_dates.
  online_order_flag: "1 si el cliente hizo el pedido online; 0 si lo hizo un comercial."
  purchase_order_number: Número de pedido de compra del cliente.
  account_number: Número de cuenta financiera del cliente.
  freight: Gastos de envío, en USD.
  credit_card_approval_code: Código de aprobación de la tarjeta de crédito.
  shipping_method: Método de envío (p. ej. CARGO TRANSPORT 5).
  sales_person: Nombre y apellidos del comercial del pedido. Vacío en los pedidos online.
  original_currency: Divisa a la que se convirtió el pedido. Vacía si el pedido no tiene tipo de cambio (USD).
  bill_country: País de la dirección de facturación.
  bill_province: Provincia o estado de la dirección de facturación.
  bill_city: Ciudad de la dirección de facturación.
  bill_address_line1: Primera línea de la dirección de facturación.
  bill_address_line2: Segunda línea de la dirección de facturación.
  bill_postal_code: Código postal de la dirección de facturación.
  ship_country: País de la dirección de envío.
  ship_province: Provincia o estado de la dirección de envío.
  ship_city: Ciudad de la dirección de envío.
  ship_address_line1: Primera línea de la dirección de envío.
  ship_address_line2: Segunda línea de la dirección de envío.
  ship_postal_code: Código postal de la dirección de envío.
  credit_card_person: Nombre y apellidos del titular de la tarjeta de crédito.
  card_type: Tipo de tarjeta de crédito (p. ej. Vista, SuperiorCard).
  card_number: Número de la tarjeta de crédito. Dato sensible.
  tax_amt: Importe de impuestos del pedido, en USD.
---

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
