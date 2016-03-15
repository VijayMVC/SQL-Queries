SELECT count(*),
--	st.student_id,
--    st.student_current_grade_code,
	sd.local_school_year,
--	sch.school_code,
--	sch.school_name,
--	sd.local_semester,
--	sd.local_term,
----	fm.mark_period,
----	fm.mark_type,
--	fm.staff_key as staff_id,
--	ste.student_current_grade_code as grade_level,
--	c.course_subject,
--	c.course_state_equivilence_code,
--	c.course_name,
--	sd.date_value as mark_date,
--	fm.mark_numeric_value,
--	scl.scale_code as letter_grade,
--	scl.scale_description as grade_description,
    FDPR.DIPLOMA_REQUIREMENT_STATUS
FROM
	K12INTEL_DW.FTBL_FINAL_MARKS fm
	INNER JOIN K12INTEL_DW.DTBL_SCALES scl on fm.scale_key = scl.scale_key
	inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on ste.student_evolve_key = fm.student_evolve_key
	inner join K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
	inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
	inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
    LEFT OUTER JOIN K12intel_dw.ftbl_diploma_requirements fdpr on fm.final_mark_key = fdpr.final_mark_key
WHERE 1=1
--    fm.mark_type in ( 'Final') 
--    and fm.high_school_credit_indicator = 'Yes'
--    and sd.local_school_year = '@ERR'
--    and st.student_id = '8407167'
--	sd.local_school_year in ( '2012-2013') --('2013-2014')
	and ste.student_current_grade_code in ('09', '10', '11', '12')
--	and st.student_id = '8393700'
GROUP BY
    sd.local_school_year, FDPR.DIPLOMA_REQUIREMENT_STATUS
order by 2 --, COURSE_NAME, MARK_DATE
