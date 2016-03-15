SELECT
	st.student_id - 1234567 as scrambled_id,
	oneyear.credits_earned as semester_credits,
	sum (fm.mark_credit_value_earned) as total_hs_credits_earned,
	round (sum (fm.mark_credit_value_earned * fm.mark_numeric_value) / sum(fm.mark_credit_value_attempted), 3) as Cum_GPA
FROM
	K12INTEL_DW.FTBL_FINAL_MARKS fm
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on fm.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = fm.student_evolve_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
	INNER JOIN (SELECT
		st.student_id,
		sd.local_school_year,
		sd.local_semester,
		sum (fm.mark_credit_value_earned) as credits_earned,
	FROM
		K12INTEL_DW.FTBL_FINAL_MARKS fm
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on fm.student_key = st.student_key
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = fm.student_evolve_Key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = fm.school_dates_key
	WHERE
		and ste.student_current_grade_code in ('09', '10', '11', '12')
		and sd.local_school_year in ('2012-2013')
	GROUP BY
		st.student_id,
		sd.local_school_year) oneyear  on oneyear.student_id = st.student_id
WHERE
	ste.student_current_grade_code in ('09', '10', '11', '12')
	and st.student_id = '8544751'
GROUP BY
	st.student_id - 1234567
ORDER BY
3
