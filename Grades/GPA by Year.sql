SELECT
		fm.student_key,
		st.student_id,
		round (sum (fm.mark_credit_value_earned * fm.mark_numeric_value) / nullif(sum(fm.mark_credit_value_attempted),0), 3) as GPA
	FROM
		K12INTEL_DW.FTBL_STUDENT_MARKS fm
		INNER JOIN K12INTEL_DW.DTBL_SCALES scl on scl.scale_key = fm.scale_key
		INNER JOIN K12INTEL_DW.DTBL_COURSES crs on fm.course_key = crs.course_key
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on fm.student_key = st.student_key
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = fm.student_evolve_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = fm.school_dates_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
	WHERE
		fm.mark_type = 'Final'
		and sd.local_school_year = '2013-2014'
		and ste.student_current_grade_code = '07'
		and crs.course_subject in ('Mathematics',
									'Social Sciences and History',
									'Reading',
									'Life and Physical Sciences' ,
									'English Language and Literature',
									'English Language Arts')
--		and rownum < 1000
--		and st.student_id = '8408202'
		and scl.scale_code <> 'P'
GROUP BY
	fm.student_key,
	st.student_id
