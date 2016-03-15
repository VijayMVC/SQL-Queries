SELECT
	susp.school_year,
	sum (susp.students_suspended) as suspended,
	sum (susp.students_served) as served,
	round (sum (susp.students_suspended)/sum (susp.students_served),3) as susp_rate
FROM
	(SELECT
		total_served.local_school_year as school_year,
		total_served.students_served,
		total_suspended.students_suspended
	FROM
		(SELECT
			count (distinct staa.student_id) as students_served,
			adm_sd.local_school_year
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS e
		  	INNER JOIN K12INTEL_DW.DTBL_STUDENTs  staa on e.student_key = staa.student_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on sch.school_key = saa.school_key
		  															and (adm_sd.local_school_year = saa.school_year or
		  																reg_sd.local_school_year = saa.school_year)
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		WHERE
            saa.school_code = '75'
			and ((e.ENROLLMENT_TYPE  =  'Actual'
			and reg_sd.LOCAL_SCHOOL_YEAR in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014'  )
			and saa.reporting_school_ind = 'Y')
			or
			(e.attendance_type = 'N'
			and saa.reporting_school_ind = 'Y'
			and adm_sd.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014'  ) ))
		GROUP BY
			adm_sd.local_school_year) total_served
	LEFT OUTER JOIN
		(SELECT
		  icd.local_school_year as school_year,
		  count (distinct staa.student_id) as students_suspended
		FROM
		  K12INTEL_DW.FTBL_DISCIPLINE d
		  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES icd on d.school_dates_key = icd.school_dates_key
		  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_key = staa.student_key
		  															and actd.local_school_year = staa.school_year
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on d.school_key = saa.school_key
		  															and actd.local_school_year = saa.school_year
		  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
		  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
		WHERE
			icd.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014'  )
			and da.DISCIPLINE_ACTION_TYPE_CODE IN ('OS', 'OSS', '37', '33')
			and saa.reporting_school_ind = 'Y'
            and saa.school_code = '75'
		GROUP BY
			icd.local_school_year
							) total_suspended
								on total_served.local_school_year = total_suspended.school_year       
	   ) susp --on susp.school_year = saa.school_year  
GROUP BY
	susp.school_year
ORDER BY 1