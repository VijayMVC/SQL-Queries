SELECT distinct
	 crs.number as course_code,
	 crs.name as course,
	-- sch.schoolid,
	 sch.name as school,
	 case when sch.schoolid in ('128', '266') then 'At-Risk' 
		when sch.schoolid in ('147', '214') then 'Contracted'
		else 'Traditional' end,
	 --cal.name as calendar,
	 sec.number,
	 --count(distinct cmtsk.taskid) AS standards_count,
	 count(distinct ros.personid) as student_count
FROM
	dbo.course crs 
	INNER JOIN dbo.Section sec on crs.courseID = sec.courseID and crs.active = 1
	INNER JOIN dbo.Roster ros on ros.sectionID = sec.sectionID and ros.enddate is null
	INNER JOIN dbo.student st on ros.personid = st.personid and st.activeyear = 1 and st.enddate is null and st.calendarid = crs.calendarid
	INNER JOIN dbo.trial tr on tr.trialid = ros.trialID and tr.active = 1
	INNER JOIN dbo.Calendar cal on cal.calendarid = crs.calendarID
	INNER JOIN dbo.School sch on sch.schoolID = cal.schoolID
WHERE
	SUBSTRING(crs.number,1,2) in ('RC','RD')
	and st.grade in ('09', '10', '11', '12')
	--and SUBSTRING(crs.number,1,4) <> 'TECH'
	--and SUBSTRING(crs.number,1,2) <> 'PE'
	--crsm.number = 'MA221'
GROUP BY
	 crs.number,
	 crs.name,
	 sec.number,
	 sch.schoolid,
	 sch.name
	 --cal.name
--HAVING 
--	count(distinct cmtsk.taskid) <  4
ORDER BY
	3,1