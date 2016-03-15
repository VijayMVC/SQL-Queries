SELECT
--	st.student_id,
--	st.student_current_grade_code,
--	st.student_current_school_code,
--	st.student_current_school,
--	stx.student_years_in_high_school,
--	ar.STUDENT_RISK_MEASURE_VALUE as SAIL_credits
	ROUND(avg(ar.STUDENT_RISK_MEASURE_VALUE), 2) as avg_SAIL_TQ_credits
FROM
	K12INTEL_DW.FTBL_STUDENTS_AT_RISK ar
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st ON ar.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_RISK_FACTORS rf ON rf.risk_factor_key = ar.risk_factor_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx ON stx.student_key = st.student_key

WHERE
	st.student_activity_indicator = 'Active' and
	st.student_status = 'Registered' and
	ST.STUDENT_CURRENT_SCHOOL_CODE in ( '90', '52', '14', '18', '69', '38', '33', '12', '41') and
	stx.student_years_in_high_school = 2 and
	(ar.STUDENT_RISK_STATUS  =  'Active'  and
	rf.risk_factor_key = '1045'  )
--GROUP BY
--	st.student_current_school_code,
--	st.student_current_school
