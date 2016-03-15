-- Summarizing course enrollments by type of course
SELECT
	count (distinct st.student_id),
	sd.local_school_year
FROM
	K12INTEL_DW.FTBL_STUDENT_SCHEDULES ss
	INNER JOIN K12INTEL_DW.DTBL_COURSES crs on crs.course_key = ss.course_key
	INNER JOIN K12INTEL_DW.DTBL_STAFF stf on stf.staff_key = ss.staff_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = ss.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on ss.school_key = schaa.school_key and schaa.school_year = sd.local_school_year
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ss.student_key
WHERE
	sd.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013')
	and crs.course_subject = 'Foreign Language and Literature'
GROUP BY
	sd.local_school_year
ORDER BY 1,2
