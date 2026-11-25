---
Description: |
  Dimensión de fechas (calendario). Una fila por día desde el 1 de enero de 2010 hasta el
  31 de diciembre del año en curso, generada a partir de la vista Crono$Dates de Crono.
  Los nombres de meses y días están en castellano.
Columns:
  date: Día natural. Clave del calendario.
  iso_date: Fecha como texto en formato ISO 8601 (p. ej. 2021-01-04).
  year: Año natural (p. ej. 2021).
  quarter: Trimestre (Q1 a Q4).
  year_quarter: Año y trimestre (p. ej. 2021-Q1).
  month_number: Número del mes (1 a 12).
  month_name: Nombre del mes (p. ej. Enero).
  year_month: Año y mes (p. ej. 2021-M01).
  day: Día del mes (1 a 31).
  week_day_name: Nombre del día de la semana (p. ej. Lunes).
  day_of_year: Día del año (1 a 366).
  iso_week_number: Número de la semana ISO 8601 (1 a 53).
  iso_week_year: |
    Año ISO de la semana. Puede no coincidir con year en los primeros
    y últimos días del año (p. ej. el 1 de enero de 2021 es de la semana 2020-W53).
  iso_week: Año ISO y semana ISO (p. ej. 2021-W01).
---

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
from crono.dates
where [year] between 2010 and year(getdate())

