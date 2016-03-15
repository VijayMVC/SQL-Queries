SELECT
	sch_susp.school_year,
	saa.school_code,
	saa.school_name,
	saa.school_current_grades,
	sum (sch_susp.students_suspended) as school_suspended,
	sum (sch_susp.students_served) as school_served,
	round (sum (sch_susp.students_suspended)/sum (sch_susp.students_served),3) as school_susp_rate,
	sum (dist_susp.students_suspended) as dist_suspended,
	sum (dist_susp.students_served) as dist_served,
	round (sum (dist_susp.students_suspended)/sum (dist_susp.students_served),3) as dist_susp_rate
FROM
	K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa
	INNER JOIN  K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	INNER JOIN (SELECT
		total_served.school_code,
		total_served.school_year,
		total_served.grade_level,
		total_served.students_served,
		total_suspended.students_suspended
	FROM
		(SELECT
			count (distinct staa.student_id) as students_served,
			sch.school_code,
			staa.school_year,
			staa.student_annual_grade_code as grade_level
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS e
		  	INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on e.student_key = staa.student_key
		  															and staa.school_year = '2012-2013'
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on sch.school_key = saa.school_key
		  															and (adm_sd.local_school_year = saa.school_year or
		  																reg_sd.local_school_year = saa.school_year)
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		WHERE
			(e.ENROLLMENT_TYPE  =  'Actual'
			and reg_sd.LOCAL_SCHOOL_YEAR in ('2012-2013' )
			and saa.reporting_school_ind = 'Y')
			or
			(e.attendance_type = 'N'
			and saa.reporting_school_ind = 'Y'
			and adm_sd.local_school_year in ('2012-2013') )
		GROUP BY
			sch.school_code,
			staa.school_year,
			staa.student_annual_grade_code) total_served
	LEFT OUTER JOIN
		(SELECT
		  actd.local_school_year as school_year,
		  count (distinct staa.student_id) as students_suspended,
		  staa.student_annual_grade_code as grade_level,
		  sch.school_code,
		  sch.school_name
		FROM
		  K12INTEL_DW.FTBL_DISCIPLINE d
		  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_key = staa.student_key
		  															and actd.local_school_year = staa.school_year
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on d.school_key = saa.school_key
		  															and (actd.local_school_year = saa.school_year or
		  																actd.local_school_year = saa.school_year)
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
		WHERE
			actd.local_school_year in ('2012-2013'  )
			and da.DISCIPLINE_ACTION_GROUP  =  'Suspension'
			and saa.reporting_school_ind = 'Y'
		GROUP BY
			actd.local_school_year,
			staa.student_annual_grade_code,
		  	sch.school_code,
		  	sch.school_name
							) total_suspended
								ON total_served.school_code = total_suspended.school_code
								and total_served.school_year = total_suspended.school_year
								and total_served.grade_level = total_suspended.grade_level
	   ) sch_susp    on sch_susp.school_code = saa.school_code  and saa.school_year = sch_susp.school_year
INNER JOIN
	(SELECT
		total_served.school_year,
		total_served.grade_level,
		total_served.students_served,
		total_suspended.students_suspended
	FROM
		(SELECT
			count (distinct staa.student_id) as students_served,
			staa.school_year,
			staa.student_annual_grade_code as grade_level
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS e
		  	INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on e.student_key = staa.student_key
		  															and staa.school_year = '2012-2013'
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on sch.school_key = saa.school_key
		  															and (adm_sd.local_school_year = saa.school_year or
		  																reg_sd.local_school_year = saa.school_year)
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		WHERE
			(e.ENROLLMENT_TYPE  =  'Actual'
			and reg_sd.LOCAL_SCHOOL_YEAR in ('2012-2013' )
			and saa.reporting_school_ind = 'Y')
			or
			(e.attendance_type = 'N'
			and saa.reporting_school_ind = 'Y'
			and adm_sd.local_school_year in ('2012-2013') )
		GROUP BY
			staa.school_year,
			staa.student_annual_grade_code) total_served
	LEFT OUTER JOIN
		(SELECT
		  actd.local_school_year as school_year,
		  count (distinct staa.student_id) as students_suspended,
		  staa.student_annual_grade_code as grade_level
		FROM
		  K12INTEL_DW.FTBL_DISCIPLINE d
		  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_key = staa.student_key
		  															and actd.local_school_year = staa.school_year
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on d.school_key = saa.school_key
		  															and (actd.local_school_year = saa.school_year or
		  																actd.local_school_year = saa.school_year)
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
		WHERE
			actd.local_school_year in ('2012-2013'  )
			and da.DISCIPLINE_ACTION_GROUP  =  'Suspension'
			and saa.reporting_school_ind = 'Y'
		GROUP BY
			actd.local_school_year,
			staa.student_annual_grade_code
							) total_suspended
								on total_served.school_year = total_suspended.school_year
								and total_served.grade_level = total_suspended.grade_level
	      ) dist_susp
	      		on sch_susp.school_year = dist_susp.school_year
   				and sch_susp.grade_level = dist_susp.grade_level
GROUP BY
	sch_susp.school_year,
	saa.school_code,
	saa.school_name,
	saa.school_current_grades
HAVING
	sum (sch_susp.students_served) > 3
ORDER BY 2
