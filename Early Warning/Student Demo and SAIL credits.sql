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
	st.student_age,
	st.student_cumulative_gpa,
	attend.attendance_percentage,
	sail.credits
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
		st.student_id,
		st.student_key,
		ar.STUDENT_RISK_MEASURE_VALUE as credits
	FROM
		  K12INTEL_DW.DTBL_STUDENTS st,
		   K12INTEL_DW.DTBL_RISK_FACTORS rf,
		  K12INTEL_DW.FTBL_STUDENTS_AT_RISK ar
		WHERE
		  ( st.STUDENT_KEY=ar.STUDENT_KEY  )
		  AND  ( rf.RISK_FACTOR_KEY= ar.RISK_FACTOR_KEY  )
		  AND
		  (
		   ar.STUDENT_RISK_STATUS  =  'Active'   )
		   and rf.risk_factor_key = '1045'  ) SAIL ON (st.student_key = sail.student_key)
WHERE
	st.student_activity_indicator = 'Active'
	and sail.credits <= '5'
	and st.student_age >= '18'
