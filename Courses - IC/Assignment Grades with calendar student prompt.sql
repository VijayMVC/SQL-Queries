--Set prompting variable
DECLARE @calendar int
DECLARE @student int

SET @calendar = 12 --Set to Calendarid to restore
SET @student = 988 --Set to Studnetnumber to restore

SELECT
	--sch.name as school_name,
	--st.studentnumber,
	--stid.lastname + ', ' + stid.firstname as student,
	crs.number as course_number,
	crs.name as course_name,
	--sec.number as section_number,
	sec.teacherdisplay,
	--tchid.lastname + ', ' + tchid.firstname as teacher,
--	lpg.name as assignment_group,
	lpa.name as assignment,
	lps.score as score
FROM
	dbo.section sec 
	INNER JOIN dbo.lessonplangroup lpg on lpg.sectionid = sec.sectionid
	INNER JOIN dbo.lessonplangroupactivity lpga on lpg.groupid = lpga.groupid --and lpga.sectionid = sec.sectionid
	INNER JOIN dbo.lessonplanactivity lpa on lpga.activityid = lpa.activityid --and sec.sectionid = lpa.sectionid
	INNER JOIN dbo.lessonplanscore lps on lps.activityid = lpa.activityid
	INNER JOIN dbo.course crs on crs.courseid = sec.courseid
	INNER JOIN dbo.person st on st.personid = lps.personid
	INNER JOIN dbo.calendar cal on cal.calendarid = crs.calendarid
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
	INNER JOIN dbo.schoolyear sy on sy.endyear = cal.endyear
	
WHERE
	--sy.active = 1
	cal.calendarid = @calendar
	and lps.personid = @student 