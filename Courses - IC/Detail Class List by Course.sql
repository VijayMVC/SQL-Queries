SELECT distinct
 --crssch.name,
 --st.studentnumber,
 --st.personid,
 --stid.lastname,
 --stid.firstname,
 -- enr.grade,
 --case when enr.specialEdStatus is null then 'N' else enr.specialEdStatus end as specialEdStatus,
 --enr.disability1

	 crsm.number as course_code,
	 crsm.name as course,
	 crssch.name as school,
	 --crscal.name as calendar,
	 --count(distinct sec.sectionId) as sections,
	 sec.sectionid,
	 sec.sectionnumber,
	 sch.termstart as term,
	 stfid.personid,
	 stf.staffNumber,
	 sec.teacherDisplay,
	 --stfid.lastname,
	 --stfid.firstname,
	 --st.personid,
	 st.studentNumber,
	 stid.lastname,
	 stid.firstname,
	 --enrsch.name,
	 --ros.startDate,
	 --ros.enddate,
	 enr.grade,
	 case when enr.specialEdStatus is null then 'N' else enr.specialEdStatus end as specialEdStatus,
	 enr.disability1
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
	INNER JOIN dbo.Calendar crscal on crscal.calendarid = crs.calendarID
	INNER JOIN dbo.School crssch on crssch.schoolID = crscal.schoolID
	INNER JOIN (dbo.Enrollment enr
					INNER JOIN dbo.calendar enrcal on enrcal.calendarID = enr.calendarID and enrcal.endYear = '2015' and enr.startdate <= getdate() and (enr.enddate is null or enr.enddate >= getdate())
					INNER JOIN dbo.school enrsch on enrsch.schoolID = enrcal.schoolID)
					on enr.personID = st.personID AND enr.calendarID = crscal.calendarID
	LEFT OUTER JOIN (dbo.GradingTaskCreditMaster cmtsk 
				INNER JOIN  dbo.GradingTask gtsk on cmtsk.taskid = gtsk.taskid and gtsk.standardID is not null
				 ) on crsm.courseMasterID = cmtsk.courseMasterID 
WHERE
	crsm.activitycode is null
	--and st.studentnumber = '8019436' 
	and SUBSTRING(crs.number,2,1) = 'E'
	and SUBSTRING(crs.number,1,4) <> 'TECH'
	and SUBSTRING(crs.number,1,2) <> 'PE'
	and SUBSTRING(crs.number,1,3) <> 'OE3'
	and sch.termstart = 'T1'
	--and enr.grade = '12'
	--and crssch.number = '0029'
	--crsm.number = 'MA221'
--GROUP BY
--	 crsm.number,
--	 crsm.name,
--	 sec.sectionId,
--	 sch.name,
--	 cal.name
--HAVING 
--	count(distinct cmtsk.taskid) <  4
--ORDER BY
--	crsm.number,
--	crssch.name,
--	sec.sectionid,
--	stid.lastname