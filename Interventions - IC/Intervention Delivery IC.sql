SELECT
	st.personid
	,st.studentnumber
	,stid.firstName
	,stid.lastName
	--,tch.staffNumber as teacher_id
	--,tchid.lastname +', ' +tchid.firstname as teacher
	,pt.contentarea
	,pt.interventionTier
	,pt.abbreviation
	,pl.startdate as plan_start_date
	,pl.enddate as plan_end_date
	--,pl.createdDate
	,ps.name as service_name
	,ps.description as service_desc
	,ps.active
	,pg.goalid
	,pg.name as goal
	,se.reportMethod
	,pg.baseScore
	,pg.goalScore
	,pg.assessmentCriteria
	--,psp.servicefrequency as freq
	--,psp.serviceFreqPeriod as freq_period
	--,psp.servicedirect as minutes
	--,psp.startDate as service_start_date
	--,psp.enddate as service_end_date
	,intd.assessmentdate as intervention_date
	,convert(time,intd.starttime) as start_time
	,convert(time,intd.endtime) as end_time
	,intd.score as intervention_score
	
FROM
	dbo.[Plan] pl
	INNER JOIN dbo.plantype pt on pt.typeid = pl.typeID
	INNER JOIN dbo.PlanServiceProvided psp on psp.planid = pl.planid 
	INNER JOIN dbo.planservice ps on ps.serviceid = psp.serviceid and psp.planid = pl.planid
	INNER JOIN dbo.plangoal pg on pg.planid = pl.planID
	INNER JOIN dbo.seplan se on se.planid = pl.planid
--	INNER JOIN dbo.PlanGoalObjective pgo on pgo.goalid = pg.goalid and pgo.planid = pl.planid
	INNER JOIN dbo.person st on st.personid = pl.personid
	INNER JOIN dbo.[Identity] stid on stid.identityID = st.currentIdentityID
	INNER JOIN dbo.person tch on tch.personid = pl.createdByID
	INNER JOIN dbo.[Identity] tchid on tchid.identityID = tch.currentIdentityID
	INNER JOIN dbo.InterventionDelivery intd on intd.goalid = pg.goalid
WHERE 1=1
	and pt.contentarea in ('Behavior', 'Attendance', 'Academic')
	--st.personid = 366708
ORDER BY
	1,intd.assessmentdate
	;
