SELECT
	st.student_id,
	st.student_key,
	st.student_name,
	st.student_current_school_code as school_code,
	st.student_current_school as school_name,
	st.student_current_grade_code as grade,
	st.student_special_ed_indicator as sped_status,
	st.student_special_ed_class as sped_cat,
	st.student_educational_except_typ as sped_type,
	ste.student_years_in_high_school,
	std.student_birthdate,
	st.student_age,
	st.student_cumulative_gpa,
	attend.attendance_percentage,
--	susp.susp_count,
	cred.credits
FROM
	K12INTEL_DW.DTBL_STUDENTS st
	LEFT OUTER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION ste ON st.student_key = ste.student_key
	LEFT OUTER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS std ON  st.student_key = std.student_key
    LEFT OUTER JOIN ( SELECT
		attd.student_key,
		--attd.school_key,
		round( (sum(attd.attendance_value)   /   sum(attd.attendance_days) )  * 100, 2) as attendance_percentage
			--	sum(case when attd.excused_absence = 'Excused Absence' then attd.attendance_days - attd.attendance_value else 0 end) as excused_absence_days,
			--  sum(case when attd.excused_absence = 'Un-Excused Absence' or attd.excused_absence = 'Unexcused Absence'  then
			--  				case when attd.excused_authorized = 'Yes' then 0 else attd.attendance_days - attd.attendance_value end else 0 end) as unexcused_absence_days
	  FROM
		K12INTEL_DW.FTBL_ATTENDANCE_STUMONABSSUM attd,
		k12intel_dw.dtbl_calendar_dates cd,
		K12INTEL_DW.DTBL_SCHOOL_DATES sd
	  WHERE
		attd.calendar_date_key  = cd.calendar_date_key
		and attd.school_dates_key = sd.school_dates_key
--		and (   sd.local_school_year = '2012-2013' )
		--		and attd.month_name_short in ('Sep', 'Oct', 'Nov', 'Dec', 'Jan')  )
	--	and enroll.student_id = '8378355'
	  GROUP BY
		attd.student_key
		--attd.school_key
		) attend  ON ( st.student_key = attend.student_key)
	LEFT OUTER JOIN ( SELECT
		 da.student_key,
 	 	 --da.school_key,
	     count(da.DISCIPLINE_ACTION_KEY)as Susp_count
	   FROM
	   	 K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da,
	   	 K12INTEL_DW.DTBL_CALENDAR_DATES susdate,
	   	 K12INTEL_DW.DTBL_SCHOOL_DATES sdsusdate
	   WHERE
	     da.CALENDAR_DATE_KEY = susdate.CALENDAR_DATE_KEY
	     and sdsusdate.school_dates_key = da.school_dates_key
	     and ( da.DISCIPLINE_ACTION_GROUP = 'Suspension'
	     	 --	and susdate.month_name_short in ('Sep', 'Oct', 'Nov', 'Dec', 'Jan')
	     		and sdsusdate.local_school_year = '2012-2013'  )
	    GROUP BY
		 da.student_key
 	 	 --da.school_key
 	 	 ) susp   ON ( st.student_key = susp.student_key)
	LEFT OUTER JOIN ( SELECT
			fm.student_key,
			st.student_id,
			sum(fm.mark_credit_value_earned) as credits
		FROM
		 	 K12INTEL_DW.FTBL_FINAL_MARKS fm
		 	 INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED se ON fm.student_evolve_key = se.student_evolve_key
		 	 INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on  fm.student_key = st.student_key
		 	 INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES creddate ON fm.calendar_date_key = creddate.calendar_date_key
			 INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sdcreddate ON fm.school_dates_key = sdcreddate.school_dates_key
		WHERE
		 	se.student_current_grade_code in ('09', '10', '11', '12')
		 --	and	creddate.date_value <= ('01-20-2013')
		GROUP BY
		   fm.student_key,
		   st.student_id ) cred ON ( st.student_key = cred.student_key)
WHERE
	st.student_id in (
	'8259654',
	'8330721',
	'8352141',
	'8335971',
	'8329839',
	'8283909',
	'8281695',
	'8420859',
	'8275704',
	'8273220',
	'8350116',
	'8044333',
	'8357205',
	'8275704',
'8400609',
'8370555'
)


;

