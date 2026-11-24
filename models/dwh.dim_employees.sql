
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

