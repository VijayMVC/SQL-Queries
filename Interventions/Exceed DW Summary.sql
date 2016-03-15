SELECT
	sch.school_code,
	sch.school_name,
	program_type,
	PROGRAM_Name,
	PROGRAM_GROUP,
	count (distinct st.student_id) as students_w_plans,
	count (distinct (case when meas.program_measure_value is not null then st.student_id else null end)) as students_w_scores
FROM
	k12intel_dw.ftbl_program_membership prgm
	inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
	INNER JOIN K12INTEL_KEYMAP.KM_PROGRAMS_EXCEED km on km.program_key = prg.program_key
	INNER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_EXT px on px.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = meas.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
	inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
	inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
	inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
WHERE
	1=1
	and membership_begin_date >= '07-01-2014'
--	and membership_status = 'Active' -- not in ('Expired','Deleted', 'Prior Year Active')
	and program_group in ('Behavior', 'Literacy', 'Math')
	and sch.school_code = '73'
--	and st.student_id = '8667052'
--	and meas.program_measure_value is not null
GROUP BY
	sch.school_code,
	sch.school_name,
	program_type,
	PROGRAM_Name,
	PROGRAM_GROUP

