SELECT
	ex.pif as student_id,
	ex.intervention,
	dw.program_name,
	ex.domain,
	dw.program_group,
	ex.status,
	dw.program_status,
	ex.begindate,
	dw.membership_begin_date,
	ex.enddate,
	dw.membership_end_date,
	dw.start_date as goal_start,
	dw.end_date as goal_end,
	ex.target,
	dw.target_value,
	ex.baseline,
	dw.baseline_value
FROM
	(SELECT
		est.pif,
		sint.lastupdatedat,
		intpl.name as intervention_plan,
		int.id,
		int.name as intervention,
		aoc.name as aoc,
		dom.name as domain,
		sint.name as program,
		sint.status,
		sint.begindate,
		sint.enddate,
		esch.schoolname,
		esch.clientschoolcode,
		sg.name as goal,
		sg.target,
		sg.baseline
--		mon.id as mon_id,
--		mon.score1
	FROM
		K12INTEL_STAGING_EXCEED.STUDENTINTERVENTION  sint
		INNER JOIN K12INTEL_STAGING_EXCEED.INTERVENTION int on sint.interventionid = int.id
		INNER JOIN K12INTEL_STAGING_EXCEED.INTERVENTIONPLAN intpl on intpl.id = sint.interventionplanid
		LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.AREAOFCONCERN aoc on aoc.id = sint.areaofconcernid
		LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.DOMAIN dom on dom.id = aoc.domainid
		INNER JOIN K12INTEL_STAGING_EXCEED.STUDENT est on sint.studentid = est.id
		INNER JOIN K12INTEL_STAGING_EXCEED.SCHOOL esch ON  sint.deliveryschoolid = esch.id
		LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.STUDENTGOAL sg on sg.interventionplanid = sint.interventionplanid
		LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.GOAL gl on gl.id = sg.goalid and gl.areaofconcernid = aoc.id
		LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.MEASURE meas on meas.id = sg.measureid  and meas.areaofconcernid = aoc.id
	--	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.PROGRESSMONITORSCORE mon on mon.studentid = sint.studentid and mon.measureid = meas.id and (mon.monitordate >= sint.begindate and (mon.monitordate <= sint.enddate or sint.enddate is null))
	WHERE
		1=1
		and esch.clientschoolcode = '73'
		and begindate >= '07-01-2014'
		and dom.name in ('Behavior', 'Literacy', 'Math')
	) EX
	LEFT OUTER JOIN
		(SELECT
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
		goal.baseline_value
--		kmeas.id as score_id,
--		meas.program_measure_value
	FROM
		k12intel_dw.ftbl_program_membership prgm
		inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
		INNER JOIN K12INTEL_KEYMAP.KM_PROGRAMS_EXCEED km on km.program_key = prg.program_key
		INNER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_EXT px on px.membership_key = prgm.membership_key
		LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
 --		LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
 --		LEFT OUTER JOIN K12INTEL_KEYMAP.KM_PROGRAM_MEASURES_EXCEED kmeas on kmeas.program_measures_key = meas.program_measures_key
--		LEFT OUTER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = meas.calendar_date_key
		INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
		inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
		inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
		inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
	WHERE
		1=1
		and membership_begin_date >= '07-01-2014'
		and program_group in ('Behavior', 'Literacy', 'Math')
		and sch.school_code = '73'
	--	and st.student_id = '8980081'
	ORDER BY
		1,6 ) DW ON DW.STUDENT_ID = EX.pif AND DW.INTERVENTION_ID = EX.id -- and dw.score_id = ex.mon_id
ORDER BY 1,2
