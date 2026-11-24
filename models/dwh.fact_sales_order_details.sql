

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
