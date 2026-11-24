
CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.dim_dates KEY date
select
	[date] date date NOT NULL PRIMARY KEY,
	iso_date,
	year,
	quarter,
	year_quarter,
	month_number,
	month_name,
	year_month,
	day,
	week_day_name,
	day_of_year,
	iso_week_number,
	iso_week_year,
	iso_week
from Crono$Dates
where [year] between 2010 and year(getdate())

