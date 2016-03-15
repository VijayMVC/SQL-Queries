SELECT distinct
	 crsm.number as course_code,
	 crsm.name as course,
	 sch.name as school,
	 --cal.name as calendar,
	 --sec.number,
	 count(distinct cmtsk.taskid) AS standards_count,
	 count(distinct ros.personid) as student_count
FROM
	dbo.coursemaster crsm
	LEFT OUTER JOIN (dbo.GradingTaskCreditMaster cmtsk 
				INNER JOIN  dbo.GradingTask gtsk on cmtsk.taskid = gtsk.taskid and gtsk.standardID is not null
				 ) on crsm.courseMasterID = cmtsk.courseMasterID 
	LEFT OUTER JOIN (dbo.course crs 
				INNER JOIN dbo.Section sec on crs.courseID = sec.courseID and crs.active = 1
				INNER JOIN dbo.Roster ros on ros.sectionID = sec.sectionID
				INNER JOIN dbo.trial tr on tr.trialid = ros.trialID and tr.active = 1
				INNER JOIN dbo.Calendar cal on cal.calendarid = crs.calendarID
				INNER JOIN dbo.School sch on sch.schoolID = cal.schoolID) on crsm.coursemasterid = crs.coursemasterid
WHERE
	crsm.activitycode is null 
	and SUBSTRING(crs.number,1,2) in ('ME','AE', 'SE', 'LE')
	and sch.number = '0029'
	--and SUBSTRING(crs.number,1,4) <> 'TECH'
	--and SUBSTRING(crs.number,1,2) <> 'PE'
	--crsm.number = 'MA221'
GROUP BY
	 crsm.number,
	 crsm.name,
	 --sec.number,
	 sch.name
	 --cal.name
--HAVING 
--	count(distinct cmtsk.taskid) <  4
ORDER BY
	1,3