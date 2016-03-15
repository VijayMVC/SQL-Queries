SELECT
	st.student_id - 123456 as scrambled_id,
	sd.local_school_year
FROM
	K12INTEL_DW.FTBL_STUDENT_SCHEDULES ss
	INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = ss.course_key
	INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = ss.staff_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = ss.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on ss.school_key = schaa.school_key and schaa.school_year = sd.local_school_year
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ss.student_key
WHERE
	sd.local_school_year in ('2013-2014')
GROUP BY
	sd.local_school_year
ORDER BY 1,2
