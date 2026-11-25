---
Description: |
  Dimensión de productos de AdventureWorks. Una fila por producto (Product) del ERP, con su
  subcategoría, categoría y modelo. Los productos sin subcategoría (componentes y material
  que no se vende) tienen la categoría y la subcategoría vacías. La carga es MERGE UPSERT:
  los productos que desaparecen del ERP no se borran.
Columns:
  product_sid: Clave subrogada del producto en el DWH.
  product_id: Identificador del producto en el ERP (Product.ProductID). Clave de negocio.
  product: Nombre del producto.
  product_category: Categoría del producto (Bikes, Components, Clothing, Accessories).
  product_subcategory: Subcategoría del producto (p. ej. Mountain Bikes).
  product_number: Código del producto (p. ej. BK-M68B-38).
  product_model: Modelo del producto.
  color: Color del producto.
  standard_cost: Coste estándar del producto, en USD.
  list_price: Precio de venta de tarifa, en USD.
  size: Talla o tamaño del producto.
  size_unit_measure_code: Unidad de medida de size (p. ej. CM).
  weight: Peso del producto.
  weight_unit_measure_code: Unidad de medida de weight (p. ej. LB, G).
  product_line: "Línea de producto: R (carretera), M (montaña), T (paseo) o S (estándar)."
  discontinued_date: Fecha en la que el producto dejó de fabricarse o venderse.
  make_flag: "1 si el producto se fabrica en la empresa; 0 si se compra."
  finished_goods_flag: "1 si el producto es vendible (producto terminado); 0 si no."
---

CREATE OR REPLACE PROCEDURE
MERGE UPSERT dwh.dim_products(product_sid)
MATERIALIZE
select
	Product.ProductID			#product_id,
	Product.Name				product,
  	ProductCategory.name 		product_category,
  	ProductSubCategory.name 	product_subcategory,
	ProductNumber				product_number,
	ProductModel.name 			product_model,
  	Color						color,
	StandardCost				standard_cost,
	ListPrice					list_price,
	Size						size,
	SizeUnitMeasureCode			size_unit_measure_code,
	Weight						weight,
	WeightUnitMeasureCode		weight_unit_measure_code,
	ProductLine					product_line,
	DiscontinuedDate			discontinued_date,
	MakeFlag					make_flag,
	FinishedGoodsFlag			finished_goods_flag
FROM @@erp.Product
LEFT JOIN @@erp.ProductSubCategory using Product(ProductSubcategoryID)
LEFT JOIN @@erp.ProductCategory using ProductSubCategory(ProductCategoryId)
LEFT JOIN @@erp.ProductModel using Product(ProductModelID)
check snowflake

