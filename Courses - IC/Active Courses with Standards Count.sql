SELECT distinct
	 crsm.number as course_code,
	 crsm.name as course,
	 --sch.name as school,
	 --cal.name as calendar,
	 --sec.sectionId,
	 count(distinct tsk.taskid) AS standards_count,
	 count(distinct ros.personid) as student_count
FROM
	dbo.coursemaster crsm
	INNER JOIN dbo.GradingTaskCreditMaster tsk on crsm.courseMasterID = tsk.courseMasterID and tsk.standardID is not null
	LEFT OUTER JOIN (dbo.course crs 
				INNER JOIN dbo.Section sec on crs.courseID = sec.courseID and crs.active = 1
				INNER JOIN dbo.Roster ros on ros.sectionID = sec.sectionID
				INNER JOIN dbo.Calendar cal on cal.calendarid = crs.calendarID
				INNER JOIN dbo.School sch on sch.schoolID = cal.schoolID) on crsm.coursemasterid = crs.coursemasterid
--WHERE 
--	SUBSTRING(crs.number,2,1) = 'E'
--	and SUBSTRING(crs.number,1,4) <> 'TECH'
--	and SUBSTRING(crs.number,1,2) <> 'PE'
--	crsm.number = 'OE911'
GROUP BY
	 crsm.number,
	 crsm.name
	 --sec.sectionId,
	 --sch.name,
	 --cal.name
HAVING 
	count(distinct tsk.taskid) <  4
ORDER BY
	1,3