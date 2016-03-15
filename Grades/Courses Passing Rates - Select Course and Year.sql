SELECT
	marks.course_area,
	marks.pass_fail,
	count(distinct marks.student_id)
FROM
	(SELECT
		staa.student_id,
		case when c.course_short_code in ('MA211', 'MA213', 'MA215', 'MA216', 'MA221', 'MA223') then 'Algebra'
			when c.course_short_code in ('EN111', 'EN101') then 'English_9' else 'Other' end as course_area,
		case when fm.mark_numeric_value = 0 then 'Failed' else 'Passed' end as pass_fail,
		c.course_short_code,
		fm.mark_numeric_value
	FROM
		K12INTEL_DW.FTBL_FINAL_MARKS fm
		inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
		inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
		inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS	staa on fm.student_key = staa.student_key and staa.school_year = '2012-2013'
		INNER JOIN
		( (SELECT
			st.student_id
		 FROM
			K12INTEL_DW.FTBL_FINAL_MARKS fm
			inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
			inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
			inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
		WHERE
			sd.local_school_year in ('2012-2013')
			and c.course_short_code in ('EN101')
		INTERSECT
		SELECT
			st.student_id
		 FROM
			K12INTEL_DW.FTBL_FINAL_MARKS fm
			inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
			inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
			inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
		WHERE
			sd.local_school_year in ('2012-2013')
			and c.course_short_code in ('EN111')  )
		UNION
		(SELECT
			st.student_id
		 FROM
			K12INTEL_DW.FTBL_FINAL_MARKS fm
			inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
			inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
			inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
		WHERE
			sd.local_school_year in ('2012-2013')
			and c.course_short_code in ('MA216', 'MA221', 'MA223')
		INTERSECT
		SELECT
			st.student_id
		 FROM
			K12INTEL_DW.FTBL_FINAL_MARKS fm
			inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
			inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
			inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
		WHERE
			sd.local_school_year in ('2012-2013')
			and c.course_short_code in ('MA211', 'MA213', 'MA215') ) )marks on staa.student_id = marks.student_id
	WHERE
		c.course_short_code in ('MA211', 'MA213', 'MA215', 'MA216', 'MA221', 'MA223', 'EN111', 'EN101')
		and sd.local_school_year = '2012-2013'
		and staa.student_annual_grade_code = '09') marks
GROUP BY
	marks.course_area,
	marks.pass_fail
