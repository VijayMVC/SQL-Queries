SELECT
	  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	  st.STUDENT_ID,
--	  sch.school_code ,
--	  sch.school_name,
--	  sx.group2,
	  count(attd.attendance_key)  as total_membership_days,
	  sum(attd.attendance_value)  as att_days,
	  round( (sum(attd.attendance_value)   /   count(attd.attendance_key) ), 3) as attendance_percentage
FROM
	k12intel_dw.dtbl_students st
	INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_code = st.student_current_school_code
	INNER JOIN k12intel_dw.dtbl_schools_extension sx on sx.school_key = sch.school_key
	LEFT OUTER JOIN (k12intel_dw.ftbl_attendance attd
	  INNER JOIN k12intel_dw.dtbl_calendar_dates c on attd.calendar_date_key  = c.calendar_date_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = attd.school_dates_key) --and sd.local_school_year = '2013-2014')
	  			on attd.student_key = st.student_key
WHERE
	st.student_activity_indicator = 'Active'
--	sch.school_code = '421' and
    and st.student_id = '8606440' 
--	sx.group1 in ('01', '02', '03', '04', '05', '06', '07', '08')          -- *** enter each school year to export seperately
GROUP BY
	sd.LOCAL_SCHOOL_YEAR ,
	st.STUDENT_ID
--	sch.SCHOOL_CODE,
--	sch.school_name,
--	sx.group2
-- having sum(attd.attendance_days) >= 20
ORDER BY 1
