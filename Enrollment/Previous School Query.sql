SELECT
	st.student_id,
	st.student_status,
	cur_sch.school_code as current_school_code,
	cur_sch.school_name as current_school,
	all_enr.school_code as prev_school_code,
	all_enr.school_name as prev_school,
	stx.student_previous_school_num,
	stx.student_previous_school_name
FROM
	K12INTEL_DW.DTBL_STUDENTS st
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS cur_sch on cur_sch.school_key = st.school_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
	LEFT OUTER JOIN
	(SELECT
		enr.student_key,
		enr.school_key,
		sch.school_code,
		sch.school_name,
		max(adm_cd.date_value) as enroll_date,
		ROW_NUMBER() OVER (PARTITION BY enr.student_key ORDER BY max(adm_cd.date_value) desc) as enrol_num
	FROM
		K12INTEL_DW.FTBL_ENROLLMENTS enr
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = enr.student_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
		INNER JOIN k12intel_dw.dtbl_calendar_dates adm_cd on enr.cal_date_key_register = adm_cd.calendar_date_key
    WHERE
    	enr.school_key <> st.school_key
    GROUP BY
    	enr.student_key,
		enr.school_key,
		sch.school_code,
		sch.school_name ) all_enr  on all_enr.student_key = st.student_key and all_enr.enrol_num = 1
WHERE
	all_enr.school_code <> to_char(stx.student_previous_school_num)
--	all_enr.school_code = to_char(stx.student_previous_school_num)
--
