SELECT
	sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	s.SCHOOL_CODE ,
	s.school_name,
	sx.group2,
	sum(a.attendance_days)  as total_membership_days,
	sum(a.attendance_days - a.attendance_value)  as total_absence_days,
	round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage
FROM
	k12intel_dw.ftbl_attendance_stumonabssum a
	INNER JOIN k12intel_dw.dtbl_calendar_dates c on  a.calendar_date_key  = c.calendar_date_key
	INNER JOIN k12intel_dw.dtbl_schools s on a.school_key = s.school_key
	INNER JOIN k12intel_dw.dtbl_schools_extension sx on s.school_key = sx.school_key
	INNER JOIN k12intel_dw.dtbl_students st on a.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on a.school_dates_key = sd.school_dates_key
WHERE
	(sd.local_school_year in ('2014-2015'))
--	and s.school_code in ('89', '220', '667', '25', '432')
group by
	sd.LOCAL_SCHOOL_YEAR,
	sx.group2,
	s.school_name,
	s.SCHOOL_CODE
order by 3,1;


