SELECT
	st.student_key,
	st.student_id,
	enr.enrollments_key,
	sch.school_key,
	sch.school_code,
	staa.student_annual_grade_code,
	case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END as grade_group,
	cd.date_value,
	enr.enrollment_days,
	ROW_NUMBER() OVER (PARTITION BY st.student_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END ORDER BY cd.date_value desc )  as enrollment_num,
	LEAD(sch.school_code,1) OVER (PARTITION BY st.student_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END ORDER BY cd.date_value desc )  as previous_enroll
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS enr
	INNER JOIN k12intel_dw.dtbl_students ST ON ST.STUDENT_KEY = enr.student_key
	INNER JOIN K12INTEL_DW.DTBL_student_annual_attribs STAA ON enr.student_annual_attribs_key = staa.student_annual_attribs_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cd on enr.cal_date_key_register = cd.calendar_date_key
	INNER JOIN K12Intel_DW.Dtbl_Schools sch ON enr.school_key = sch.school_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx ON enr.SCHOOL_KEY =  schx.school_KEY
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED se on enr.STUDENT_EVOLVE_KEY = se.STUDENT_EVOLVE_KEY
WHERE
	enr.enrollment_days > 39
	and st.student_key <> 0
	and st.student_id = '8578801'
--	AND ROWNUM < 10000
ORDER BY
	st.student_key 
