SELECT distinct
	sch.name as school_name,
	sec.sectionid,
	crs.name as course_name,
	crs.number as course_number,
	term.name as term,
	sec.number as section_number,
	CHAR(34)+tchid.lastname + ', ' + tchid.firstname+CHAR(34) as teacher_name,
	CHAR(34)+stid.lastname + ', ' + stid.firstname+CHAR(34) as student_name,
	p.name as period_name,
	r.name as room
FROM
	dbo.section sec 
	INNER JOIN dbo.sectionstaff secstf on sec.sectionid = secstf.sectionid
	INNER JOIN dbo.sectionplacement secpl on secpl.sectionid = sec.sectionid
	INNER JOIN dbo.trial on trial.trialid = sec.trialid
	INNER JOIN dbo.room r on r.roomid = sec.roomid
	INNER JOIN dbo.term on term.termid = secpl.termid
	INNER JOIN dbo.period p on p.periodid = secpl.periodid
	INNER JOIN dbo.course crs on crs.courseid = sec.courseid
	INNER JOIN dbo.person tch on tch.personid = secstf.personid
	INNER JOIN dbo.[identity] tchid on tchid.identityid = tch.currentidentityid
	INNER JOIN dbo.roster ros on ros.sectionid = sec.sectionid
	INNER JOIN dbo.trial tr on tr.trialID = ros.trialID and tr.active = 1
	INNER JOIN dbo.person st on st.personid = ros.personid
	INNER JOIN dbo.[identity] stid on stid.identityid = st.currentidentityid
	INNER JOIN dbo.calendar cal on cal.calendarid = crs.calendarid
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
	INNER JOIN dbo.schoolyear sy on sy.endyear = cal.endyear
WHERE
	sy.active = 1
	and trial.active = 1
	--and term.startdate <= getdate() and term.enddate >= getdate()
--	and sch.number = 546
--	and ros.enddate is null
--	and term.name = 'Q1'
ORDER BY
	sch.name, crs.name, sec.number --, stid.lastname, stid.firstname