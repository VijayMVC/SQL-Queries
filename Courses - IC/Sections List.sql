SELECT 
        --  sec.STAGE_SOURCE
         sec.SECTIONID
        , sec.TRIALID
        , sec.COURSEID
        , sec."NUMBER"
        , sec.TEACHERDISPLAY
        , sec.MAXSTUDENTS
        , sec.CLASSTYPE
        , sec.SCHEDGROUPID
        , sec.ROOMID
        , sec.LUNCHID
        , sec.LUNCHCOUNT
        , sec.MILKCOUNT
        , sec.ADULTCOUNT
        , sec.SERVICEDISTRICT
        , sec.SERVICESCHOOL
        , sec.MULTIPLETEACHERCODE
        , sec.LOCKBUILD
        , sec.LOCKROSTER
        , sec.GIFTEDDELIVERY
        , sec.GIFTEDCONTENTAREA
        , sec.TEACHERPERSONID
        , sec.PARAPROS
        , sec.SKINNYSEQ
        , sec.LEGACYKEY
        , sec.HIGHLYQUALIFIED
        , sec.HOMEROOMSECTION
        , sec.TEACHINGMETHOD
        , sec.SECTIONGUID
        , sec."LOCK"
        , sec.NONHQTREASON
        , sec.NONHQTEXPLANATION
        , sec.SPEDAREA
        , cal.DISTRICTID
        , cal.SCHOOLID
        , cal.ENDYEAR
        , crs.DEPARTMENTID
        , crs.GRADE
        , crs."NUMBER" COURSE_CODE
        , crs."NAME" COURSE_NAME
        , sch."NUMBER" SCHOOL_CODE
       -- , dis."NUMBER" DISTRICT_CODE
    FROM DBO.SECTION sec
    INNER JOIN DBO.TRIAL t
        ON sec.TRIALID = t.TRIALID 
       -- AND sec.STAGE_SOURCE = t.STAGE_SOURCE
    INNER JOIN DBO.CALENDAR cal
        ON t.CALENDARID = cal.CALENDARID 
       -- AND t.STAGE_SOURCE = cal.STAGE_SOURCE
	INNER JOIN DBO.SchoolYear sy
		on sy.endyear = cal.endYear
    INNER JOIN DBO.COURSE crs
        ON sec.COURSEID = crs.COURSEID 
      --  AND sec.stage_source = crs.stage_source
    INNER JOIN DBO.SCHOOL sch
        ON cal.SCHOOLID = sch.SCHOOLID 
       -- AND cal.STAGE_SOURCE = sch.STAGE_SOURCE 
   -- INNER JOIN DBO.DISTRICT dis
     --   ON cal.DISTRICTID = dis.DISTRICTID 
       -- AND cal.STAGE_SOURCE = dis.STAGE_SOURCE
    WHERE 1 = 1
       -- AND sec.STAGE_DELETEFLAG = 0
       -- AND t.ACTIVE = 1
        AND sy.active = 1
		and CRS.NUMBER = 'MU151'
        and sch.number = '0018'
 ORDER BY
    5
;
select sec.* from DBO.COURSE crs 
inner join dbo.section sec on sec.courseid = crs.courseid 
inner join dbo.trial t on t.trialid = sec.trialid 
inner join dbo.calendar cal on cal.calendarid = t.calendarid
inner join dbo.school sch on sch.schoolid = cal.schoolID
inner join dbo.schoolyear sy on sy.endyear = cal.endYear
where crs.calendarid = 3252 and crs.number = 'MU151';
select * from dbo.calendar where schoolid = 7