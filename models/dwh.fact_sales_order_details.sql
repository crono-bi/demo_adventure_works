---
Description: |
  Hechos de líneas de pedidos de venta de AdventureWorks. Una fila por línea de pedido
  (SalesOrderDetail) del ERP, con su producto, su pedido y la oferta especial aplicada.
  Los datos de cabecera (cliente, fechas, direcciones) están en dwh.fact_sales_order_header.
  Los importes están en USD.
Columns:
  sales_order_detail_sid: Clave subrogada de la línea de pedido en el DWH.
  sales_order_detail_id: Identificador de la línea en el ERP (SalesOrderDetail.SalesOrderDetailID). Clave de negocio.
  product_sid: Producto vendido. Referencia a dwh.dim_products.
  sales_order_sid: Pedido al que pertenece la línea. Referencia a dwh.fact_sales_order_header.
  carrier_tracking_number: Número de seguimiento del transportista.
  order_qty: Unidades pedidas.
  unit_price: Precio unitario de venta, en USD.
  unit_price_discount: Descuento sobre el precio unitario, en tanto por uno (0.1 = 10 %).
  line_total: "Importe de la línea, en USD: unit_price * (1 - unit_price_discount) * order_qty."
  special_offer: Descripción de la oferta especial aplicada (p. ej. No Discount).
  special_offer_type: Tipo de la oferta especial (p. ej. Volume Discount).
  special_offer_category: Categoría de la oferta especial (p. ej. Reseller).
---

CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.fact_sales_order_details(sales_order_detail_sid)
SELECT
	SalesOrderDetail.SalesOrderDetailID			#sales_order_detail_id,
	dim_products.product_sid					product_sid					REFERENCES dwh.dim_products,
	fact_sales_order_header.sales_order_sid		sales_order_sid				REFERENCES dwh.fact_sales_order_header,
	SalesOrderDetail.CarrierTrackingNumber		carrier_tracking_number,
	SalesOrderDetail.OrderQty					order_qty,
	SalesOrderDetail.UnitPrice					unit_price,
	SalesOrderDetail.UnitPriceDiscount			unit_price_discount,
	SalesOrderDetail.LineTotal					line_total,

	SpecialOffer.Description					special_offer,
	SpecialOffer.Type							special_offer_type,
	SpecialOffer.Category						special_offer_category,
from @@erp.SalesOrderDetail materialize SalesOrderDetail
REMOTE inner join @@erp.SalesOrderHeader using SalesOrderDetail(SalesOrderID)
REMOTE inner join @@erp.SpecialOffer using SalesOrderDetail(SpecialOfferID)
REMOTE inner join @@erp.Product using SalesOrderDetail(ProductID)
inner join dwh.dim_products using Product(ProductID product_id)
inner join dwh.fact_sales_order_header using SalesOrderHeader(SalesOrderID sales_order_id)
check snowflake
