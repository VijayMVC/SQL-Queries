SELECT 
	sch.schoolid,
	sch.name,
	count(per.personid) as enrollment,
	cast(sum(case when id.raceethnicity = '1' then 1 else 0 end)/(count(per.personid)*1.0)as decimal(10,3)) as Hispanic,
	cast(sum(case when id.raceethnicity = '2' then 1 else 0 end)/(count(per.personid)* 1.0) as decimal(10,3))  as Native_Am,
	cast(sum(case when id.raceethnicity = '3' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3))  as Asian,
	cast(sum(case when id.raceethnicity = '4' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3)) as Black,
	cast(sum(case when id.raceethnicity = '5' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3))  as HI_PI,
	cast(sum(case when id.raceethnicity = '6' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3))  as White,
	cast(sum(case when id.raceethnicity = '7' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3))  as Multi,
	cast(sum(case when enr.specialedstatus = 'Y' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3)) as SpEd,
	cast(sum(case when pos.eligibility in ('F', 'R') then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3)) as Econ_Dis,
	cast(sum(case when lep.programstatus = 'LEP' then 1 else 0 end)/(count(per.personid)* 1.0)as decimal(10,3)) as LEP
FROM
	dbo.Enrollment enr WITH (NOLOCK)
	INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
	INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
    INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
    INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
	INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	LEFT OUTER JOIN dbo.poseligibility pos on pos.personid = enr.personid and pos.endyear = enr.endyear and (pos.startdate <= getdate() and pos.enddate is null or pos.enddate >= getdate())  
	LEFT OUTER JOIN dbo.LEP on  lep.personid = enr.personid
WHERE
	 sy.active = 1
	 and enr.startdate <= getdate() and (enr.enddate is null or enr.enddate >= getdate())
GROUP BY
	sch.schoolid,
	sch.name
ORDER BY 1