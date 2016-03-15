SELECT
	  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	  st.STUDENT_ID,
	  cd.day_name_short,
	  cd.date_value,
	  cd.day_of_month,
	  sch.school_code,
	  sch.school_name,
      attd.absence_reason,
	  attd.attendance_value
FROM
	k12intel_dw.ftbl_attendance attd
    INNER JOIN k12intel_dw.dtbl_students st on attd.student_key = st.student_key
	INNER JOIN k12intel_dw.dtbl_schools sch ON attd.school_key = sch.school_key
	INNER JOIN k12intel_dw.dtbl_schools_extension sx on sx.school_key = sch.school_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = attd.school_dates_key
	  			
WHERE 1=1 
	and sd.date_value > to_date('09-01-2015', 'MM-DD-YYYY')
    and st.student_id = '8707792'
ORDER BY 4,2
;
