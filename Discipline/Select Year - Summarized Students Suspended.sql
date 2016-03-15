SELECT
  actd.local_school_year,
  count (distinct st.student_id) as students_suspended,
  sch.school_code,
  sch.school_name
FROM
  K12INTEL_DW.FTBL_DISCIPLINE d
  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on d.student_evolve_key = ste.student_evolve_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on d.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  incd on d.school_dates_key = incd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on d.school_key = saa.school_key
  															and (actd.local_school_year = saa.school_year or
  																incd.local_school_year = saa.school_year)
  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
WHERE
	actd.local_school_year in ('2013-2014'  )
	and da.DISCIPLINE_ACTION_TYPE  =  'Suspension'
	and saa.reporting_school_ind = 'Y'
GROUP BY
	actd.local_school_year,
  	sch.school_code,
  	sch.school_name  
ORDER BY 
	3
