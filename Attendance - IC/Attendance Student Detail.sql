SELECT
	per.studentNumber,
	sch.number,
	sch.name,
	attd.date,
	attd.status,
	attd.excuse,
	attdx.code,
	attdx.description,
	attdx.status,
	attdx.excuse,
	attd.presentminutes,
	attd.comments	
FROM
	dbo.person per
	INNER JOIN dbo.enrollment enr on per.personid = enr.personid
	INNER JOIN dbo.calendar cal on cal.calendarid = enr.calendarid
	INNER JOIN dbo.schoolyear sy on sy.endyear = cal.endyear
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
	INNER JOIN dbo.attendance attd on attd.personid = per.personid and attd.calendarid = cal.calendarid
	INNER JOIN dbo.AttendanceExcuse attdx on attd.excuseid = attdx.excuseid
WHERE
	sy.active = 1
	and sch.number = '0116'
	and substring(attdx.code,1,1) = 'S'
ORDER BY 
1