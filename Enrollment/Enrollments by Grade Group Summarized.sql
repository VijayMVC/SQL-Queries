SELECT
	st.student_key,
	st.student_id,
	sch.school_key,
	sch.school_code,
	case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END as grade_group,
	min(adm.date_value) as first_enroll,
	max(wd.date_value) as end_enroll,
--	SUM(enr.enrollment_days) OVER (PARTITION BY staa.student_key, sch.school_key) as total_enroll_days,
	DENSE_RANK() OVER (PARTITION BY st.student_key, sch.school_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END ORDER BY min(adm.date_value) )  as enrollment_num,
	LEAD(sch.school_code,1) OVER (PARTITION BY st.student_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END ORDER BY min(adm.date_value) desc )  as previous_enroll
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS enr
	INNER JOIN k12intel_dw.dtbl_students ST ON ST.STUDENT_KEY = enr.student_key
	INNER JOIN K12INTEL_DW.DTBL_student_annual_attribs STAA ON enr.student_annual_attribs_key = staa.student_annual_attribs_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates adm_cd on enr.cal_date_key_register = adm_cd.calendar_date_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates wd_cd on enr.cal_date_key_end_enroll = wd_cd.calendar_date_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates adm_sd on enr.school_dates_key_register = adm_sd.school_dates_key
	INNER JOIN k12intel_dw.dtbl_school_dates wd_sd on enr.school_dates_key_end_enroll = wd_sd.school_dates_key
	INNER JOIN K12Intel_DW.Dtbl_Schools sch ON enr.school_key = sch.school_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx ON enr.SCHOOL_KEY =  schx.school_KEY
WHERE
	enr.enrollment_days > 39
	and st.student_key <> 0
	and st.student_id = '8578801'
GROUP BY
	st.student_key,
	st.student_id,
	sch.school_key,
	sch.school_code,
	case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
		when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
		else 'ELEM' END
ORDER BY
	st.student_key
