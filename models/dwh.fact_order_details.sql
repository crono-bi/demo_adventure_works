---
Description: |
  Hechos de líneas de pedido de Northwind. Una fila por línea de @@stg.order_details
  (un producto de un pedido). Desnormaliza la fecha del pedido y calcula los importes
  bruto, de descuento y neto. Los datos del pedido están en dwh.fact_orders.
Columns:
  order_detail_sid: Clave subrogada de la línea en el DWH.
  order_sid: Pedido al que pertenece la línea. Referencia a dwh.fact_orders. Con product_sid, clave de negocio.
  product_sid: Producto vendido. Referencia a dwh.dim_products. Con order_sid, clave de negocio.
  order_date: Fecha del pedido, copiada de su cabecera. Referencia a dwh.dim_dates.
  quantity: Unidades vendidas.
  unit_price: Precio unitario de venta, antes del descuento.
  discount: Descuento sobre el precio, en tanto por uno (0.15 = 15 %).
  gross_amount: "Importe bruto: unit_price * quantity."
  discount_amount: "Importe del descuento: gross_amount - net_amount (unit_price * quantity * discount, redondeado)."
  net_amount: "Importe neto: gross_amount - discount_amount."
---

CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.fact_order_details(order_detail_sid) KEY (order_sid, product_sid)
SELECT
	fact_orders.order_sid										order_sid			REFERENCES dwh.fact_orders,
	dim_products.product_sid									product_sid			REFERENCES dwh.dim_products,
	fact_orders.order_date										order_date			REFERENCES dwh.dim_dates([date]),
	order_details.quantity										quantity,
	order_details.unit_price									unit_price,
	order_details.discount										discount,
	round(order_details.unit_price * order_details.quantity, 2)								gross_amount		decimal(12,2),
	-- Difference of the rounded amounts, so gross_amount - discount_amount = net_amount exactly.
	round(order_details.unit_price * order_details.quantity, 2)
		- round(order_details.unit_price * order_details.quantity * (1 - order_details.discount), 2)	discount_amount		decimal(12,2),
	round(order_details.unit_price * order_details.quantity * (1 - order_details.discount), 2)	net_amount			decimal(12,2)
FROM @@stg.order_details
INNER JOIN dwh.fact_orders USING order_details(order_id)
INNER JOIN dwh.dim_products USING order_details(product_id)
CHECK SNOWFLAKE
