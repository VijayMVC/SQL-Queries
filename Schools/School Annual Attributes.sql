SELECT
	distinct sch.school_code,
	saa.school_state_id,
	saa.school_name,
	saa.school_type,
	saa.school_current_grades,
	saa.school_grades_group,
	saax.mps_sch_group_code,
	saax.region,
	saax.dpi_monitoring_level
FROM
  	K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa
  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on saa.school_key = sch.school_key
  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
WHERE
	saa.school_year = '2013-2014'
	and saa.reporting_school_ind = 'Y'
order by 1
