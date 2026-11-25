
-- Checks the quality of the Northwind data in staging before loading the dwh.
-- Each ASSERT stops the load with its message if the query returns any row.
-- Running this file (re)creates the procedure; the workflow runs it with PROCEDURE dbo.initial_checks.


CREATE OR REPLACE PROCEDURE dbo.initial_checks
BEGIN

	-- Quantities and prices must be positive
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.order_details: there are lines with a quantity of zero or less.'
	SELECT order_id, product_id
	FROM staging.order_details
	WHERE quantity <= 0

	ASSERT THAT NOT EXISTS ELSE THROW 'staging.order_details: there are lines with a unit price of zero or less.'
	SELECT order_id, product_id
	FROM staging.order_details
	WHERE unit_price <= 0

	ASSERT THAT NOT EXISTS ELSE THROW 'staging.products: there are products with a unit price of zero or less.'
	SELECT product_id
	FROM staging.products
	WHERE unit_price <= 0

	-- Discounts are a fraction between 0 and 1 (0.15 = 15 %)
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.order_details: there are lines with a discount outside the range from 0 to 1.'
	SELECT order_id, product_id
	FROM staging.order_details
	WHERE discount < 0 OR discount >= 1

	-- Stock cannot be negative
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.products: there are products with negative units in stock or on order.'
	SELECT product_id
	FROM staging.products
	WHERE units_in_stock < 0 OR units_on_order < 0

	-- Order dates must be consistent
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.orders: there are orders without an order date.'
	SELECT order_id
	FROM staging.orders
	WHERE order_date IS NULL

	ASSERT THAT NOT EXISTS ELSE THROW 'staging.orders: there are orders shipped before their order date.'
	SELECT order_id
	FROM staging.orders
	WHERE shipped_date < order_date

	ASSERT THAT NOT EXISTS ELSE THROW 'staging.orders: there are orders required before their order date.'
	SELECT order_id
	FROM staging.orders
	WHERE required_date < order_date

	-- Freight cannot be negative
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.orders: there are orders with negative freight.'
	SELECT order_id
	FROM staging.orders
	WHERE freight < 0

	-- Every customer needs a country (dim_customers derives sales_area from it)
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.customers: there are customers without a country.'
	SELECT customer_id
	FROM staging.customers
	WHERE country IS NULL OR country = ''

	-- Each employee must appear only once
	ASSERT THAT NOT EXISTS ELSE THROW 'staging.employees: there are repeated employees.'
	SELECT employee_id
	FROM staging.employees
	GROUP BY employee_id
	HAVING count(*) > 1

END
