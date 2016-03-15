SELECT
	  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	  st.STUDENT_ID,
	  cd.day_name_short,
	  cd.date_value,
	  cd.day_of_month,
	  sch.school_code,
	  sch.school_name,
	  sum(attd.attendance_days)  as total_membership_days,
	  sum(attd.attendance_value)  as att_days,
	  round( (sum(attd.attendance_value)   /   sum(attd.attendance_days) ), 2) as attendance_percentage
FROM
	k12intel_dw.ftbl_attendance_stumonabssum attd
    INNER JOIN k12intel_dw.dtbl_students st on attd.student_key = st.student_key
	INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_code = st.student_current_school_code
	INNER JOIN k12intel_dw.dtbl_schools_extension sx on sx.school_key = sch.school_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = attd.school_dates_key
	  			
WHERE
	sd.local_school_year = '2014-2015' 
    and st.student_id = '8548708'
GROUP BY
	sd.LOCAL_SCHOOL_YEAR ,
	st.STUDENT_ID,
	cd.day_name_short,
	cd.date_value,
	cd.day_of_month,
	sch.SCHOOL_CODE,
	sch.school_name
ORDER BY 4,2
