---
Description: |
  Dimensión de empleados de AdventureWorks. Una fila por empleado (Employee) del ERP,
  incluidos los que ya no trabajan en la empresa (current_flag = 0).
Columns:
  employee_sid: Clave subrogada del empleado en el DWH.
  employee_id: Identificador del empleado en el ERP (Employee.BusinessEntityID). Clave de negocio.
  national_id_number: Número de identificación nacional del empleado.
  login_id: Usuario de red del empleado (p. ej. adventure-works\ken0).
  job_title: Puesto de trabajo.
  birth_date: Fecha de nacimiento.
  marital_status: "Estado civil: M (casado) o S (soltero)."
  gender: "Sexo: M (hombre) o F (mujer)."
  hire_date: Fecha de contratación.
  salaried_flag: "1 si el empleado es asalariado (sin horas extra); 0 si cobra por horas."
  vacation_hours: Horas de vacaciones disponibles.
  sick_leave_hours: Horas de baja por enfermedad disponibles.
  current_flag: "1 si el empleado está activo; 0 si ya no trabaja en la empresa."
---

CREATE OR  REPLACE PROCEDURE
MERGE CLONE dwh.dim_employees(employee_sid)
select
	BusinessEntityID			#employee_id int NOT NULL,
	NationalIDNumber			national_id_number,
	LoginID						login_id,
	JobTitle					job_title,
	BirthDate					birth_date,
	MaritalStatus				marital_status NULL,
	Gender						gender,
	HireDate					hire_date,
	SalariedFlag				salaried_flag,
	VacationHours				vacation_hours,
	SickLeaveHours				sick_leave_hours,
	CurrentFlag					current_flag
from @@erp.Employee

