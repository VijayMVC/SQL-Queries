SELECT
	est.pif,
	esch.schoolname,
	esch.clientschoolcode,
	sint.lastupdatedat,
	intpl.name as intervention_plan,
	int.name as intervention,
	aoc.name as aoc,
	dom.name as domain,
	sint.name as program,
	sint.status,
	sint.begindate,
	sint.enddate,
	sg.name as goal,
	sg.target,
	sg.baseline,
	meas.name as measure,
	mon.monitordate,
	mon.id as mon_id,
	mon.score1
FROM
	K12INTEL_STAGING_EXCEED.STUDENTINTERVENTION  sint
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.INTERVENTION int on sint.interventionid = int.id
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.INTERVENTIONPLAN intpl on intpl.id = sint.interventionplanid and sint.studentid = intpl.studentid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.AREAOFCONCERN aoc on aoc.id = sint.areaofconcernid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.DOMAIN dom on dom.id = aoc.domainid
	INNER JOIN K12INTEL_STAGING_EXCEED.STUDENT est on sint.studentid = est.id
	INNER JOIN K12INTEL_STAGING_EXCEED.SCHOOL esch ON  sint.deliveryschoolid = esch.id
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.STUDENTGOAL sg on sg.interventionplanid = sint.interventionplanid and sg.studentid = sint.studentid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.MEASURE meas on meas.id = sg.measureid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.PROGRESSMONITORSCORE mon on mon.studentid = sint.studentid and mon.measureid = meas.id and (mon.monitordate >= sint.begindate and (mon.monitordate <= sint.enddate or sint.enddate is null))
WHERE
	1=1
	and esch.clientschoolcode = '73'
	and begindate >= '07-01-2014'
	and dom.name in ('Math') -- ('Behavior', 'Literacy', 'Math')
--	and st.student_name like ('Anderson%')
--	and est.pif = '8751940'
--	int.name = 'SAIG Emotional Management'
--	and st.student_current_grade_code = '03';
--	and mon.score1 is null
ORDER BY
	est.pif, int.name, sint.begindate --, mon.monitordate
