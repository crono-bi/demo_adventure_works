---
Description: |
  Dimensión de productos de Northwind. Una fila por producto de staging.products.
  Desnormaliza su categoría y su proveedor, y calcula el estado del stock.
  La carga es MERGE UPSERT: los productos que desaparecen del origen no se borran.
Columns:
  product_sid: Clave subrogada del producto en el DWH.
  product_id: Identificador del producto en el origen. Clave de negocio.
  product: Nombre del producto.
  category: Categoría del producto (p. ej. Beverages, Seafood).
  supplier: Nombre de la empresa proveedora.
  supplier_country: País del proveedor.
  quantity_per_unit: Formato de venta (p. ej. 10 boxes x 20 bags).
  list_price: Precio de tarifa actual del producto.
  units_in_stock: Unidades en almacén.
  units_on_order: Unidades pedidas al proveedor y pendientes de recibir.
  reorder_level: Nivel de stock por debajo del cual hay que volver a pedir.
  discontinued: "1 si el producto está descatalogado; 0 si no."
  stock_status: |
    Estado del stock: Discontinued (descatalogado), Out of stock (sin unidades),
    Reorder (el stock más lo pedido no llega al nivel de pedido) u OK.
---

CREATE OR REPLACE PROCEDURE
MERGE UPSERT dwh.dim_products(product_sid) KEY (product_id)
SELECT
	products.product_id				product_id,
	products.product_name			product,
	categories.category_name		category,
	suppliers.company_name			supplier,
	suppliers.country				supplier_country,
	products.quantity_per_unit		quantity_per_unit,
	products.unit_price				list_price,
	products.units_in_stock			units_in_stock,
	products.units_on_order			units_on_order,
	products.reorder_level			reorder_level,
	int(products.discontinued)		discontinued,
	CASE
		WHEN products.discontinued = 1 THEN 'Discontinued'
		WHEN products.units_in_stock = 0 THEN 'Out of stock'
		WHEN products.units_in_stock + products.units_on_order <= products.reorder_level THEN 'Reorder'
		ELSE 'OK'
	END								stock_status
FROM staging.products
LEFT JOIN staging.categories USING products(category_id)
LEFT JOIN staging.suppliers USING products(supplier_id)
CHECK SNOWFLAKE
