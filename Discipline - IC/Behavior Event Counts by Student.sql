SELECT
	id.firstname,
	id.lastname,
	per.studentnumber,
	sch.name as school_name,
	bty.name as behavior_event,
	bty.code as behavior_code,
	inc.timestamp,
	rol.role,
	rol.comments
	--count (distinct evt.eventid) as events
FROM
	dbo.BehaviorEvent evt
	INNER JOIN dbo.behaviorincident inc on inc.incidentid = evt.incidentID
	INNER JOIN dbo.behaviortype bty on bty.typeid = evt.typeid
	INNER JOIN dbo.behaviorrole rol on rol.eventid = evt.eventid
	LEFT OUTER JOIN (dbo.behaviorresolution res 
					INNER JOIN dbo.behaviorrestype resty on resty.typeid = res.typeid) on rol.roleid = res.roleid
	INNER JOIN dbo.person per on per.personid = rol.personid
	INNER JOIN dbo.[identity] id on id.identityid = per.currentidentityid
	INNER JOIN dbo.enrollment enr on enr.personid = per.personid
	INNER JOIN dbo.calendar cal on cal.calendarid = enr.calendarid and evt.calendarid = cal.calendarid
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
	INNER JOIN dbo.schoolyear sy on sy.endyear = cal.endyear
WHERE
	sy.active = 1
--	AND PER.STUDENTNUMBER = '8976388'
	and rol.role = 'Participant'
--GROUP BY
--	id.firstname,
--	id.lastname,
--	per.studentnumber,
--	sch.name,
--	evt.name,
--	bty.code,
--	bty.name,
--	bty.alignment
ORDER BY
	INC.TIMESTAMP