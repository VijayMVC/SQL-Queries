SELECT
	st.student_id,
--	sch.school_code,
--	sch.school_name,
--	ste.student_current_grade_code as grade,
	sd.local_school_year,
--	sd.local_semester,
--	sd.local_grading_period,
--	fm.mark_numeric_value,
--	fm.mark_credit_value_attempted,
--	sum (fm.mark_credit_value_earned) as credits_earned,
	round (sum (fm.mark_credit_value_earned * fm.mark_numeric_value) / sum(fm.mark_credit_value_attempted), 3) as GPA
FROM
	K12INTEL_DW.FTBL_FINAL_MARKS fm
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on fm.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = fm.student_evolve_Key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = fm.school_dates_key
WHERE
	st.student_id = '8544751'
	and ste.student_current_grade_code in ('09', '10', '11', '12')
	and sd.local_school_year in ('2012-2013', '2013-2014')
GROUP BY
	st.student_id,
--	sch.school_code,
--	sch.school_name,
--	ste.student_current_grade_code,
	sd.local_school_year
--	sd.local_semester,
--	sd.local_grading_period,
--	fm.mark_numeric_value,
--	fm.mark_credit_value_attempted,
--	fm.mark_credit_value_earned
ORDER BY
3
