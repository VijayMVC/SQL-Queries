SELECT
    sch.school_code,
    sch.school_name,
    crs.COURSE_CODE,
    crs.course_name,
    crs.course_subject,
    co.staff_key,
    co.room_key,
    sd.local_school_year,
    sd.date_value,
    co.course_section_start_date,
    co.course_section_end_date,
    co.course_section,
    co.course_section_name,
    co.course_period
--    stf.staff_name
FROM
	K12INTEL_DW.DTBL_COURSE_OFFERINGS co
	INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = co.course_key
--	INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = co.staff_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = co.school_dates_key
--	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on co.school_annual_attribs_key = schaa.school_annual_attribs_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = co.school_key
WHERE
    1=1
	and sd.local_school_year = '2014-2015'
    and sch.school_code = '18'
    and crs.course_code = 'MU151'
 --   and stf.staff_employee_id = '126326'
ORDER BY 3,1,2
