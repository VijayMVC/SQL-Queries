SELECT
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
	and da.DISCIPLINE_ACTION_TYPE  =  'Suspension'
	and saa.reporting_school_ind = 'Y'
	and sch.school_code = '18'
GROUP BY
	actd.local_school_year,
	staa.student_annual_grade_code,
  	sch.school_code,
  	sch.school_name
