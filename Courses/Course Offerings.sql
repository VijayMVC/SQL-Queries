SELECT distinct
	crs.course_short_code,
	crs.course_state_equivilence_code,
	crs.course_subject,
	crs.COURSE_CODE,
	crs.COURSE_SHORT_NAME,
	crs.course_name
FROM
	K12INTEL_DW.DTBL_COURSE_OFFERINGS co
	INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = co.course_key
--	INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = ss.staff_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = co.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on co.school_key = schaa.school_key and schaa.school_year = sd.local_school_year
WHERE
	sd.local_school_year = '2012-2013'
ORDER BY 3,1,2
