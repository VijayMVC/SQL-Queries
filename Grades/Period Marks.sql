SELECT
	st.student_id,
	sch.school_code,
	sch.school_name,
	ste.student_current_grade_code as grade,
	sd.local_school_year,
	sd.local_semester,
	sd.local_grading_period,
--	pm.mark_numeric_value,
--	pm.mark_credit_value_attempted,
--	pm.mark_credit_value_earned,
	round (sum (pm.mark_credit_value_earned * pm.mark_numeric_value) / sum(pm.mark_credit_value_attempted), 3) as GPA
FROM
	K12INTEL_DW.FTBL_PERIOD_MARKS pm
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on pm.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = pm.student_evolve_Key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = pm.school_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = pm.school_dates_key
WHERE
	st.student_id = '8544751'
	and sd.local_school_year in ('2012-2013', '2013-2014')
GROUP BY
	st.student_id,
	sch.school_code,
	sch.school_name,
	ste.student_current_grade_code,
	sd.local_school_year,
	sd.local_semester,
	sd.local_grading_period
--	pm.mark_numeric_value,
--	pm.mark_credit_value_attempted,
--	pm.mark_credit_value_earned
