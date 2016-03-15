SELECT
	student_id,
	sch.school_code,
	sch.school_name,
	program_type,
	program_status,
	PROGRAM_Name,
	PROGRAM_GROUP,
	program_subgroup,
    prgm.membership_status,
    prgm.program_intervention_level,
	goal.goal_name,
	cd.date_value as score_date,
	meas.program_measure_value,
	goal.target_value,
	goal.baseline_value
FROM
	k12intel_dw.ftbl_program_membership prgm
	inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
	LEFT OUTER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = meas.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on prgm.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
WHERE
	1=1
	and bdsd.local_school_year = '2015-2016'
--	and membership_status = 'Inactive' -- not in ('Expired','Deleted', 'Prior Year Active')
	and program_group in ('Behavior') --, 'Literacy', 'Math')
--	and sch.school_code = '73'
 --   and ST.student_key IN ('372973')
--	and st.student_id = '8231531'
--	and goal.membership_key is null
ORDER BY
	1,6, cd.date_value
;
SELECT
    student_id,
    sch.school_code,
    sch.school_name,
    program_type,
    program_status,
    PROGRAM_Name,
    PROGRAM_GROUP,
    program_subgroup ,
    goal.goal_name,
    cd.date_value as goal_date,
--    meas.program_measure_value,
    goal.target_value,
    goal.baseline_value,
--    prgm.*,
    meas.*
FROM
    k12intel_dw.ftbl_program_membership prgm
    inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
    LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
    LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
    LEFT OUTER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = meas.calendar_date_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on prgm.student_key = st.student_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
WHERE
    1=1
    and bdsd.local_school_year = '2014-2015'
--    and membership_status = 'Active' -- not in ('Expired','Deleted', 'Prior Year Active')
    and program_group in ('Behavior') --, 'Literacy', 'Math')
--    and sch.school_code = '73'
    and ST.student_key IN ('306769')
--    and st.student_id = '8252052'
--    and meas.program_measure_value is not null
order by cd.date_value