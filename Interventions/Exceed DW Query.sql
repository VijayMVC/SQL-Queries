SELECT
	student_id,
	sch.school_code,
	sch.school_name,
	km.intervention_id,
	program_type,
	program_status,
	PROGRAM_Name,
	PROGRAM_GROUP,
	program_subgroup  ,
	px.membership_begin_date,
	px.membership_end_date,
	prgm.membership_status,
	prgm.program_intervention_level,
	prgm.membership_days,
	goal.goal_name,
	goal.start_date,
	goal.end_date,
	goal.target_value,
	goal.baseline_value,
	cd.date_value,
--	kmeas.id,
	meas.program_measure_value
FROM
	k12intel_dw.ftbl_program_membership prgm
	inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
	INNER JOIN K12INTEL_KEYMAP.KM_PROGRAMS_EXCEED km on km.program_key = prg.program_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_EXT px on px.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
--	LEFT OUTER JOIN K12INTEL_KEYMAP.KM_PROGRAM_MEASURES_EXCEED kmeas on kmeas.program_measures_key = meas.program_measures_key
	LEFT OUTER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = meas.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
	inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
	inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
	inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
WHERE
	1=1
	and membership_begin_date >= to_date('07-01-2014', 'MM-DD-YYYY')
--	and membership_status = 'Active' -- not in ('Expired','Deleted', 'Prior Year Active')
	and program_group in ('Behavior', 'Literacy', 'Math')
--	and sch.school_code = '73'
	and st.student_id = '8822725'
--	and meas.program_measure_value is not null
ORDER BY
	1,6, date_value

