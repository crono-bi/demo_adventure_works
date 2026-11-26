---
Description: |
  Dimensión de empleados (comerciales) de Northwind. Una fila por empleado de @@stg.employees.
  Desnormaliza el nombre de su jefe y la región de ventas de sus territorios.
Columns:
  employee_sid: Clave subrogada del empleado en el DWH.
  employee_id: Identificador del empleado en el origen. Clave de negocio.
  employee: Nombre y apellidos del empleado.
  title: Puesto de trabajo (p. ej. Sales Representative).
  birth_date: Fecha de nacimiento.
  hire_date: Fecha de contratación.
  age_at_hire: Edad, en años cumplidos, el día de su contratación.
  city: Ciudad del empleado.
  country: País del empleado.
  manager: Nombre y apellidos del jefe directo. Vacío si no tiene jefe.
  sales_region: Región de ventas de los territorios que tiene asignados (Eastern, Western, Northern, Southern).
  territories_count: Número de territorios que tiene asignados.
---

CREATE OR REPLACE PROCEDURE
MERGE CLONE dwh.dim_employees(employee_sid) KEY (employee_id)
SELECT
	employees.employee_id									employee_id,
	concat(employees.first_name, ' ', employees.last_name)	employee,
	employees.title											title,
	date(employees.birth_date)								birth_date,
	date(employees.hire_date)								hire_date,
	floor(days_between(employees.birth_date, employees.hire_date) / 365.25)	age_at_hire,
	employees.city											city,
	employees.country										country,
	concat(managers.first_name, ' ', managers.last_name)	manager,
	employee_regions.sales_region							sales_region,
	employee_regions.territories_count						territories_count
FROM @@stg.employees
LEFT JOIN @@stg.employees managers USING employees(reports_to employee_id)
LEFT JOIN (
	SELECT
		employee_territories.employee_id,
		min(trim(region.region_description))	sales_region,
		count(*)								territories_count
	FROM @@stg.employee_territories
	INNER JOIN @@stg.territories USING employee_territories(territory_id)
	INNER JOIN @@stg.region USING territories(region_id)
	GROUP BY employee_territories.employee_id
) employee_regions USING employees(employee_id)
CHECK SNOWFLAKE
