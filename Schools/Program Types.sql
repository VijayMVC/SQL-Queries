SELECT distinct
	sch.school_code,
	saa.school_state_id,
	saa.school_name,
	saa.school_type,
	saa.school_current_grades,
	saa.school_grades_group,
	saax.mps_sch_group_code,
	saax.region,
	saax.dpi_monitoring_level,
	case when sch.school_code in ('34', '76',  '182', '214', '390', '672') then 'Full Bilingual'
		when sch.school_code in ( '356', '95', '191', '193', '223', '337', '362', '301', '295', '344', '145', '39', '82', '676') then 'ESL'
		when sch.school_code in ('73', '316', '125', '173', '202', '232', '250', '256', '274', '307', '313', '318', '41', '6', '12', '34', '18', '26', '29', '32') then 'Partial Bilingual'
		when sch.school_code in ('261', '188', '105', '119', '158', '428', '268') then 'Montessori'
		when sch.school_code in ('7', '20', '21', '85') then 'IB'
		when sch.school_code in ('140', '146', '167', '277', '387') then 'Immersion'
		else null end as Program
FROM
  	K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa
  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on saa.school_key = sch.school_key
  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
WHERE
	saa.school_year in ('2013-2014')
	and saa.reporting_school_ind = 'Y'
order by 1
