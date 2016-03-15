SELECT * 
FROM
	(SELECT 
		rank() over (partition by per.personid, enr.endyear order by enr.startdate desc) as r, 
		per.studentnumber,
		enr.enrollmentid,
		sch.name as school,
		cal.name as calendar,
		enr.grade,
		enr.startdate,
		enr.enddate,
		enr.endStatus,
		enr.endyear,
		enr.nextCalendar,
		enr.nextgrade 
	FROM
		dbo.Enrollment enr WITH (NOLOCK)
		INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
		INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
		INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.active = 1 and (sy.endyear = enr.endyear or sy.endyear + 1 = enr.endyear)
		INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
		INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	WHERE 1=1
		 and per.studentNumber = '8613019'
		 and enr.stateexclude <> 1
		 --and (enr.enddate is null or enr.enddate >= getdate()) 
		 ) top_enr
WHERE top_enr.r = 1