SELECT
	  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	  st.STUDENT_ID,
	  s.SCHOOL_CODE ,
	  s.school_name,
	  sx.group2,
	  sum(a.attendance_days)  as total_membership_days,
	  sum(a.attendance_days - a.attendance_value)  as total_absence_days,
	  sum(case when a.excused_absence = 'Excused Absence' then a.attendance_days - a.attendance_value else 0 end) as excused_absence_days,
	  sum(case when a.excused_absence = 'Un-Excused Absence' or a.excused_absence = 'Unexcused Absence'  then
	  				case when a.excused_authorized = 'Yes' then 0 else a.attendance_days - a.attendance_value end
	  			else 0 end) as unexcused_absence_days,
	  round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage,
	  case when ((sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
	  FROM
	  		k12intel_dw.ftbl_attendance_stumonabssum a,
	       k12intel_dw.dtbl_calendar_dates c,
	       k12intel_dw.dtbl_schools s,
	       k12intel_dw.dtbl_schools_extension sx,
	       k12intel_dw.dtbl_students st,
	       k12intel_dw.dtbl_students_evolved se,
	       K12INTEL_DW.DTBL_SCHOOL_DATES sd
	 WHERE
	       a.calendar_date_key  = c.calendar_date_key
	       and a.school_dates_key = sd.school_dates_key
	       AND a.school_key = s.school_key
	       AND a.student_key = st.student_key
	       and se.student_evolve_key  = a.student_evolve_key
	       and  s.school_key = sx.school_key
	       and s.school_code = '193'
--	       and sx.group1 in ('01', '02', '03', '04', '05', '06', '07', '08')
	       and se.student_current_grade_code not in ('hs', 'k3', 'k4')  -- only use for accountability
	       and (sd.local_school_year = '2012-2013' )          -- *** enter each school year to export seperately
	GROUP BY
	  		sd.LOCAL_SCHOOL_YEAR ,
	 		st.STUDENT_ID,
	 		s.SCHOOL_CODE,
	 		 s.school_name,
	  		sx.group2
	having sum(a.attendance_days) >= 20
