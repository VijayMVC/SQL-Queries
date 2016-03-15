SELECT
	sch.name as school_name,
	cal.calendarid,
	crs.number as course_number,
	crs.name as course_name,
	sec.number as section_number,
	tchid.lastname + ', ' + tchid.firstname as teacher_name
	lpg.name as assignment_group,
	lpa.name as assignment_name,
	lps.score as score
FROM
	dbo.section sec 
	INNER JOIN dbo.sectionstaff secstf on sec.sectionid = secstf.sectionid
	INNER JOIN dbo.sectionplacement secpl on secpl.sectionid = sec.sectionid
	INNER JOIN dbo.trial on trial.trialid = sec.trialid
	INNER JOIN dbo.room r on r.roomid = sec.roomid
	INNER JOIN dbo.term on term.termid = secpl.termid
	INNER JOIN dbo.period p on p.periodid = secpl.periodid
	INNER JOIN dbo.lessonplangroup lpg on lpg.sectionid = sec.sectionid
	INNER JOIN dbo.lessonplangroupactivity lpga on lpg.groupid = lpga.groupid and lpga.sectionid = sec.sectionid
	INNER JOIN dbo.lessonplanactivity lpa on lpga.activityid = lpa.activityid and sec.sectionid = lpa.sectionid
	INNER JOIN dbo.course crs on crs.courseid = sec.courseid
	INNER JOIN dbo.person tch on tch.personid = secstf.personid
	INNER JOIN dbo.[identity] tchid on tchid.identityid = tch.currentidentityid
	INNER JOIN dbo.roster ros on ros.sectionid = sec.sectionid
	INNER JOIN dbo.person st on st.personid = ros.personid
	INNER JOIN dbo.[identity] stid on stid.identityid = st.currentidentityid
	INNER JOIN dbo.calendar cal on cal.calendarid = crs.calendarid
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
	INNER JOIN dbo.schoolyear sy on sy.endyear = cal.endyear
	INNER JOIN dbo.lessonplanscore lps on lps.activityid = lpa.activityid and lps.personid = st.personid
WHERE
	sy.active = 1
	and st.studentnumber = '19934' 