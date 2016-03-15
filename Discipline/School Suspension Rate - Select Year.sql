SELECT
	total_served.school_code,
	total_suspended.school_name,
	total_served.school_year,
 --	total_served.grade_level,
	total_served.students_served,
	total_suspended.students_suspended,
	round(total_suspended.students_suspended/total_served.students_served, 3) as susp_rate
FROM
	(SELECT
		count (distinct staa.student_id) as students_served,
		sch.school_code,
		staa.school_year
	 --	staa.student_annual_grade_code as grade_level
	FROM
		K12INTEL_DW.FTBL_ENROLLMENTS e
	  	INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on e.student_annual_attribs_key = staa.student_annual_attribs_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = e.school_annual_attribs_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	WHERE
		(e.ENROLLMENT_TYPE  =  'Actual'
		and reg_sd.LOCAL_SCHOOL_YEAR in ('2014-2015' )
		and saa.reporting_school_ind = 'Y'
		and e.enrollment_days > 2
		and extract(month from adm_sd.date_value) <> 7)
	GROUP BY
		sch.school_code,
		staa.school_year
	 --	staa.student_annual_grade_code
	 ) total_served
	LEFT OUTER JOIN
	(SELECT
	  actd.local_school_year as school_year,
	  count (distinct staa.student_id) as students_suspended,
	--  staa.student_annual_grade_code as grade_level,
	  sch.school_code,
	  sch.school_name
	FROM
	  K12INTEL_DW.FTBL_DISCIPLINE d
	  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
	  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_annual_attribs_key = staa.student_annual_attribs_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = d.school_annual_attribs_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
	WHERE
		actd.local_school_year in ('2014-2015'  )
		and da.DISCIPLINE_ACTION_TYPE_CODE IN ('OS', 'OSS', '33', '37')
		and saa.reporting_school_ind = 'Y'
	GROUP BY
		actd.local_school_year,
	 --	staa.student_annual_grade_code,
	  	sch.school_code,
	  	sch.school_name
						) total_suspended
							ON total_served.school_code = total_suspended.school_code
							and total_served.school_year = total_suspended.school_year
						 --	and total_served.grade_level = total_suspended.grade_level
ORDER BY 2
