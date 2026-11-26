---
Description: |
  Hechos de pedidos de Northwind. Una fila por pedido de @@stg.orders, con su cliente,
  su comercial y sus fechas. Desnormaliza la empresa de transporte y los totales de sus
  líneas, y calcula los días de envío y si el pedido se envió tarde. Las líneas de cada
  pedido están en dwh.fact_order_details.
Columns:
  order_sid: Clave subrogada del pedido en el DWH.
  order_id: Número del pedido en el origen. Clave de negocio.
  customer_sid: Cliente que hace el pedido. Referencia a dwh.dim_customers.
  employee_sid: Comercial que gestiona el pedido. Referencia a dwh.dim_employees.
  order_date: Fecha del pedido. Referencia a dwh.dim_dates.
  required_date: Fecha en la que el cliente necesita el pedido. Referencia a dwh.dim_dates.
  shipped_date: Fecha de envío. Vacía si el pedido no se ha enviado. Referencia a dwh.dim_dates.
  order_status: "Shipped si el pedido se ha enviado; Pending si no."
  days_to_ship: Días entre el pedido y su envío. Vacío si no se ha enviado.
  is_late: "1 si el pedido se envió después de la fecha requerida; 0 si no o si no se ha enviado."
  shipper: Empresa de transporte (p. ej. Speedy Express).
  ship_city: Ciudad de destino del envío.
  ship_country: País de destino del envío.
  freight: Gastos de envío del pedido.
  lines_count: Número de líneas del pedido.
  order_amount: Importe neto del pedido, con descuentos y sin gastos de envío. Suma de net_amount de sus líneas.
---

CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.fact_orders(order_sid) KEY (order_id)
SELECT
	orders.order_id								order_id,
	dim_customers.customer_sid					customer_sid		REFERENCES dwh.dim_customers,
	dim_employees.employee_sid					employee_sid		REFERENCES dwh.dim_employees,
	date(orders.order_date)						order_date			REFERENCES dwh.dim_dates([date]),
	date(orders.required_date)					required_date		REFERENCES dwh.dim_dates([date]),
	date(orders.shipped_date)					shipped_date		REFERENCES dwh.dim_dates([date]),
	if(orders.shipped_date IS NULL, 'Pending', 'Shipped')	order_status,
	days_between(orders.order_date, orders.shipped_date)	days_to_ship,
	if(orders.shipped_date > orders.required_date, 1, 0)	is_late,
	shippers.company_name						shipper,
	orders.ship_city							ship_city,
	orders.ship_country							ship_country,
	orders.freight								freight,
	order_totals.lines_count					lines_count,
	order_totals.order_amount					order_amount		decimal(12,2)
FROM @@stg.orders
INNER JOIN dwh.dim_customers USING orders(customer_id)
INNER JOIN dwh.dim_employees USING orders(employee_id)
LEFT JOIN @@stg.shippers USING orders(ship_via shipper_id)
LEFT JOIN (
	SELECT
		order_id,
		count(*)													lines_count,
		-- Same rounding per line as net_amount in dwh.fact_order_details, so the totals match.
		sum(round(unit_price * quantity * (1 - discount), 2))		order_amount
	FROM @@stg.order_details
	GROUP BY order_id
) order_totals USING orders(order_id)
CHECK SNOWFLAKE
