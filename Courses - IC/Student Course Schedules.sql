SELECT
	 crssch.name as school,
	--crscal.name as calendar,
	 crs.number as course_code,
	 crs.name as course,
	 count (distinct sec.sectionid) as sections,
	 count (distinct stf.personid) as teachers,
	 count (distinct st.personid) as students		  
FROM
	dbo.coursemaster crsm
	INNER JOIN dbo.course crs on crs.courseMasterID = crsm.courseMasterID
	INNER JOIN dbo.v_SectionInfo sec on crs.courseID = sec.courseID and crs.active = 1
	INNER JOIN dbo.v_SectionSchedule sch on sch.sectionID = sec.sectionID
	INNER JOIN dbo.person stf on stf.personid = sec.teacherPersonID
	INNER JOIN dbo.[Identity] stfid on stf.currentIdentityID = stfid.identityid	
	INNER JOIN dbo.Roster ros on ros.sectionID = sec.sectionID and (ros.enddate is null or ros.enddate >= getdate())
	INNER JOIN dbo.Person st on st.personid = ros.personid
	INNER JOIN dbo.[Identity] stid on stid.identityID = st.currentIdentityID
	LEFT OUTER JOIN (dbo.Enrollment enr
					INNER JOIN dbo.calendar enrcal on enrcal.calendarID = enr.calendarID and enrcal.endYear = '2015' and enr.startdate <= getdate() and (enr.enddate is null or enr.enddate >= getdate())
					INNER JOIN dbo.school enrsch on enrsch.schoolID = enrcal.schoolID)
					on enr.personID = st.personID
	INNER JOIN dbo.Calendar crscal on crscal.calendarid = crs.calendarID
	INNER JOIN dbo.School crssch on crssch.schoolID = crscal.schoolID
	LEFT OUTER JOIN (dbo.GradingTaskCreditMaster cmtsk 
				INNER JOIN  dbo.GradingTask gtsk on cmtsk.taskid = gtsk.taskid and gtsk.standardID is not null
				 ) on crsm.courseMasterID = cmtsk.courseMasterID 
	
WHERE
	crsm.activitycode is null
	--and st.studentnumber = '8640565' 
	and SUBSTRING(crs.number,2,1) = 'E'
	and SUBSTRING(crs.number,1,4) <> 'TECH'
	and SUBSTRING(crs.number,1,2) <> 'PE'
	and SUBSTRING(crs.number,1,3) <> 'OE3'
	and sch.termstart = 'T1'
	--and crssch.number = '0029'
	--crsm.number = 'MA221'
GROUP BY
	 crssch.name,
	 crscal.name,
	 crs.number,
	 crs.name
ORDER BY
	1,3