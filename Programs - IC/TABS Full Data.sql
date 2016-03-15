SELECT
	per.studentnumber,
	per.stateid,
	id.firstname,
	id.lastname,
	id.raceethnicity,
	case when enr.enddate <= getdate() then 'Not Currently Enrolled' else 'Enrolled' end as enroll_status,
	enr.name as current_or_last_school,
	enr.grade,
	enr.startdate,
	enr.enddate,
	convert(date,tabs.date,130) as status_date,
	cont.value as tabs_contactdate,
	coalesce(cont.value,(convert(date,tabs.date,130))) as tabs_date,
	dispdic.name as tabs_disposition,
	centerdic.name as tabs_center,
	contydic.name as tabs_contact_type,
	rundic.name as tabs_runaway,
	areadic.name as tabs_area,
	row_number() over (partition by per.studentnumber, tabs.date order by tabs.date)
FROM	
	dbo.person per
	INNER JOIN dbo.[identity] id on per.currentIdentityID = id.identityid 
	INNER JOIN
		 (SELECT distinct
			cs.personid,
			cs.date
		FROM
			dbo.customstudent cs
		WHERE
			cs.attributeid in (655, --abs code, 
							656, --bmcw contact
							657, --date of contact
							658, --disp code
							662, --narrative
							663, --parentcontacttime
							664, --prior arrest
							665, --prob contact
							667, --runaway
							668, --school contact time
							669, --tabs center
							670, --tabs contact person
							671, --tabs contact type
							1905, --tabs field stop
							673, --time in
							674, --time out
							675 ) ) tabs --type of area
			 on tabs.personid = per.personid
	LEFT OUTER JOIN dbo.customstudent cont on cont.date = tabs.date 
									and cont.personid = per.personid 
									and cont.attributeid = 657
	LEFT OUTER JOIN (dbo.customstudent disp
					INNER JOIN dbo.CampusDictionary dispdic on disp.attributeid = dispdic.attributeID and disp.value = dispdic.code)
									 on disp.date = tabs.date 
									and disp.personid = per.personid 
									and disp.attributeid = 658
	LEFT OUTER JOIN (dbo.customstudent center
					INNER JOIN dbo.CampusDictionary centerdic on center.attributeid = centerdic.attributeID and center.value = centerdic.code)
									 on center.date = tabs.date 
									and center.personid = per.personid 
									and center.attributeid = 669
	LEFT OUTER JOIN (dbo.customstudent conty
					INNER JOIN dbo.CampusDictionary contydic on conty.attributeid = contydic.attributeID and conty.value = contydic.code)
									 on conty.date = tabs.date 
									and conty.personid = per.personid 
									and conty.attributeid = 671
	LEFT OUTER JOIN (dbo.customstudent run
					INNER JOIN dbo.CampusDictionary rundic on run.attributeid = rundic.attributeID and run.value = rundic.code)
									 on run.date = tabs.date 
									and run.personid = per.personid 
									and run.attributeid = 667
	LEFT OUTER JOIN (dbo.customstudent area
					INNER JOIN dbo.CampusDictionary areadic on area.attributeid = areadic.attributeID and area.value = areadic.code)
									 on area.date = tabs.date 
									and area.personid = per.personid 
									and area.attributeid = 675
	LEFT OUTER JOIN
		(SELECT
			per.personid,
			sch.name,
			enr.grade,
			enr.startdate,
			enr.enddate 
		FROM
			dbo.Enrollment enr WITH (NOLOCK)
			INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
			INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
			INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
			INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
			INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
			INNER JOIN (SELECT enr.personid, max(enr.startdate) as max_date
						FROM dbo.Enrollment enr 
							INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
						WHERE 
							sy.active = 1
						GROUP BY
							enr.personid) max_enr on max_enr.personid = per.personid and max_enr.max_date = enr.startdate
			 )enr on enr.personid = tabs.personid

WHERE 1=1
--	coalesce(cont.value,(convert(date,tabs.date,130))) between '11-02-2014' and '11-06-2014'
	and coalesce(cont.value,(convert(date,tabs.date,130))) >= '07-01-2014'

ORDER BY
	tabs.date,
	per.studentnumber