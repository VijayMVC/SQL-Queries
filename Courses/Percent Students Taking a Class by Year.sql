SELECT
	enrolled.local_school_year,
	enrolled.course_subject,
	enrolled.total_enrolled,
	served.students_served,
	round(enrolled.total_enrolled / served.students_served, 3) as pct_enrolled
FROM
	(SELECT
		count (distinct st.student_id) as total_enrolled,
		crs.course_subject,
		sd.local_school_year
	FROM
		K12INTEL_DW.FTBL_STUDENT_SCHEDULES ss
		INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = ss.course_key
		INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = ss.staff_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = ss.school_dates_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on ss.school_key = schaa.school_key and schaa.school_year = sd.local_school_year
		INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ss.student_key
	WHERE
		sd.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014')
		and crs.course_subject = 'Foreign Language and Literature'
	GROUP BY
		sd.local_school_year,
		crs.course_subject
	ORDER BY 1,2 ) enrolled
	INNER JOIN
	(SELECT
		count (distinct e.student_key) as students_served,
		adm_sd.local_school_year
	FROM
		K12INTEL_DW.FTBL_ENROLLMENTS e
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES end_sd ON e.school_dates_key_end_enroll = end_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on sch.school_key = saa.school_key
	  															and (adm_sd.local_school_year = saa.school_year or
	  																reg_sd.local_school_year = saa.school_year or
	  																end_sd.local_school_year = saa.school_year)
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	WHERE
		((e.ENROLLMENT_TYPE  =  'Actual'
		and reg_sd.LOCAL_SCHOOL_YEAR in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014' )
		and saa.reporting_school_ind = 'Y')
		or
		(e.attendance_type = 'N'
		and saa.reporting_school_ind = 'Y'
		and adm_sd.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014' )) )
	GROUP BY
		adm_sd.local_school_year
	ORDER by
		2    ) served on served.local_school_year = enrolled.local_school_year
ORDER BY
	1
