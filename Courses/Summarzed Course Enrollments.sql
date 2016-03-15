-- Full course enrollments for each student
SELECT
--	gu_courses.course_area,
	gu_courses.AP_IB,
	count(distinct gu_courses.student_id)
FROM
	(SELECT
		st.student_id,
		sd.local_school_year,
		schaa.school_code,
		schaa.school_name,
		ss.schedule_start_date as course_start,
		ss.schedule_end_date as course_end,
		case when crs.course_short_code in ('MS411', 'MS901', 'MS921') then 'Pre_Algebra'
			 when crs.course_state_equivilence_code like '01%' or crs.course_state_equivilence_code like '51%' then 'ELA'
			 when crs.course_state_equivilence_code like '0212%' then 'Calculus'
			 when substr(crs.course_state_equivilence_code,1,5) in ('03051', '03052', '03053', '03054', '03055', '03056', '03057', '03058', '03059', '03060', '03061', '03062', '03063', '03099') then 'Biology'
			 when substr(crs.course_state_equivilence_code,1,5) in ('03151', '03152', '03153', '03155', '03156', '03157', '03159', '03160', '03161', '03162', '03199') then 'Physics'
			 when substr(crs.course_state_equivilence_code,1,5) in ('02071', '02072', '02073', '02074', '02075', '02079') then 'Geometry'
			 when substr(crs.course_state_equivilence_code,1,5) in ('03101', '03102', '03103', '03104', '03105', '03106', '03107', '03108', '03149') then 'Chemistry'
			 when substr(crs.course_state_equivilence_code,1,5) in ('02056', '02055') then 'Algebra_II'
			 when substr(crs.course_state_equivilence_code,1,5) in ('02110') then 'Pre_Calc'
			 when substr(crs.course_state_equivilence_code,1,5) in ('02106') then 'Trigonometry'
			 when substr(crs.course_state_equivilence_code,1,5) in ('02052', '02053', '02054', '02058', '02069', '02074', '02155', '02156') then 'Algebra_I'
			 else 'Other' end as course_area,
		case when crs.course_short_name like 'AP %' then 'AP'
		 	 when crs.course_short_name like 'IB %' then 'IB' else null end as AP_IB,
	    crs.course_short_code,
		crs.COURSE_CODE,
		crs.COURSE_SHORT_NAME,
		stf.staff_employee_id,
		stf.staff_name
	FROM
		K12INTEL_DW.FTBL_STUDENT_SCHEDULES ss
		INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = ss.course_key
		INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = ss.staff_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = ss.school_dates_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on ss.school_key = schaa.school_key and schaa.school_year = sd.local_school_year
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ss.student_key
		INNER JOIN
		(SELECT
			st.student_key
		FROM
		  K12INTEL_DW.FTBL_ENROLLMENTS E
		  INNER JOIN K12INTEL_DW.DTBL_STUDENTS ST ON E.STUDENT_KEY = ST.STUDENT_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  Reg_SD on e.school_dates_key_register=reg_sd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  END_SD on e.school_dates_key_end_enroll=end_sd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = e.school_key
		WHERE
			(reg_sd.local_school_year in ('2012-2013') and
			sch.school_code in ('12', '41', '90', '256', '6', '52', '59', '14', '18', '69', '38', '33')  and
			e.entry_grade_code in  ('07', '08') and
			end_sd.date_value >= to_date('03/30/2013', 'MM/DD/YYYY'))
		UNION
		SELECT
			st.student_key
		FROM
		  K12INTEL_DW.FTBL_ENROLLMENTS E
		  INNER JOIN K12INTEL_DW.DTBL_STUDENTS ST ON E.STUDENT_KEY = ST.STUDENT_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  Reg_SD on e.school_dates_key_register=reg_sd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  END_SD on e.school_dates_key_end_enroll=end_sd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = e.school_key
		WHERE
			(reg_sd.local_school_year in ('2013-2014') and
			sch.school_code in ('12', '41', '90', '256', '6', '52', '59', '14', '18', '69', '38', '33')  and
			e.entry_grade_code in  ('08', '09') and
			reg_sd.date_value <= to_date('03/31/2014', 'MM/DD/YYYY'))
		Order by
		1    )  gu_st on gu_st.student_key = st.student_key
	WHERE
		schaa.school_code in ('12', '41', '90', '256', '6', '52', '59', '14', '18', '69', '38', '33')  and
		((sd.local_school_year = '2012-2013' and ss.schedule_end_date >= to_date('03/30/2013', 'MM/DD/YYYY')) or
		(sd.local_school_year = '2013-2014' and ss.schedule_start_date <= to_date('03/31/2014', 'MM/DD/YYYY')))
		) gu_courses
GROUP BY
--	gu_courses.course_area
	gu_courses.AP_IB
ORDER BY 1,2
