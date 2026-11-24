

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

