SELECT
	esch.schoolname,
	esch.clientschoolcode,
	int.name as intervention,
	aoc.name as aoc,
	dom.name as domain,
	sint.name as program,
	count(distinct sint.studentid) as students_w_plans,
	count (distinct(case when mon.score1 is not null then sint.studentid else null end)) as students_w_scores
FROM
	K12INTEL_STAGING_EXCEED.STUDENTINTERVENTION  sint
	INNER JOIN K12INTEL_STAGING_EXCEED.INTERVENTION int on sint.interventionid = int.id
	INNER JOIN K12INTEL_STAGING_EXCEED.INTERVENTIONPLAN intpl on intpl.id = sint.interventionplanid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.AREAOFCONCERN aoc on aoc.id = sint.areaofconcernid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.DOMAIN dom on dom.id = aoc.domainid
	INNER JOIN K12INTEL_STAGING_EXCEED.SCHOOL esch ON  sint.deliveryschoolid = esch.id
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.STUDENTGOAL sg on sg.interventionplanid = sint.interventionplanid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.MEASURE meas on meas.id = sg.measureid
	LEFT OUTER JOIN K12INTEL_STAGING_EXCEED.PROGRESSMONITORSCORE mon on mon.studentid = sint.studentid and mon.measureid = meas.id and (mon.monitordate >= sint.begindate and (mon.monitordate <= sint.enddate or sint.enddate is null))
WHERE
	1=1
	and esch.clientschoolcode = '73'
	and begindate >= '07-01-2014'
	and dom.name in ('Behavior', 'Literacy', 'Math')
--	and st.student_name like ('Anderson%')
--	and st.student_id = '8667052'
GROUP BY
	esch.schoolname,
	esch.clientschoolcode,
	int.name,
	aoc.name,
	dom.name,
	sint.name
ORDER BY
	1,2,3,4
