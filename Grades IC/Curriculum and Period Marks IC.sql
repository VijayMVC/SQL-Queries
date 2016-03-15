SELECT  
        gs.SCOREID
        , gs.CALENDARID
        , gs.PERSONID
        , gs.SECTIONID
        , gs.TERMID
        , gs.TASKID
        , gs.SCORE
--        , gs.percent
        , gs.date
        , gs.COMMENTS
        , gt.STANDARDID
        , gt.TRANSCRIPT
        , gt.NAME GRADINGTASK_NAME
        , cal.ENDYEAR
        , trm.name PERIOD_NAME
        , trm.ENDDATE
        , per.STUDENTNUMBER
        , sch.number SCHOOL_CODE    
        , dis.number DISTRICT_CODE
        , COALESCE(gtc.SCOREGROUPID,curr.SCOREGROUPID) SCOREGROUPID
        , crs."NUMBER" COURSE_CODE
FROM 
	dbo.GRADINGSCORE gs
	INNER JOIN dbo.GRADINGTASK gt
		ON gs.TASKID = gt.TASKID
	INNER JOIN dbo.CALENDAR cal
		ON gs.CALENDARID = cal.CALENDARID
	LEFT JOIN dbo.TERM trm
		ON gs.TERMID = trm.TERMID
	INNER JOIN dbo.PERSON per
		ON gs.PERSONID = per.PERSONID
	INNER JOIN dbo.SCHOOL sch
		ON cal.SCHOOLID = sch.SCHOOLID
	INNER JOIN dbo.DISTRICT dis
		ON cal.DISTRICTID = dis.DISTRICTID
	LEFT JOIN dbo.SECTION sec --NOT ALL SECTIONS JOIN OUT?
		ON gs.SECTIONID = sec.SECTIONID 
	LEFT JOIN dbo.GRADINGTASKCREDIT gtc  --CAN CAUSE CARTESIAN?  LAST RECORD WINS FOR NOW.
		ON sec.COURSEID = gtc.COURSEID 
		AND gs.CALENDARID = gtc.CALENDARID 
		AND gs.TASKID = gtc.TASKID 
	LEFT JOIN dbo.CURRICULUMSTANDARD curr
		ON gt.STANDARDID = curr.STANDARDID
	LEFT JOIN dbo.course crs
		ON sec.COURSEID = crs.COURSEID
WHERE 1=1
            and per.studentnumber = '8601511'