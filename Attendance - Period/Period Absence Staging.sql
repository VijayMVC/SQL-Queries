SELECT 
          att.STAGE_SOURCE
        , att.ATTENDANCEID
        , att.CALENDARID
        , att.PERSONID
        , att.PERIODID
        , att."DATE"
        , att.STATUS
        , att.EXCUSE
        , att.PRESENTMINUTES
        , att.COMMENTS
        , att.EXCUSEID
        , cal.ENDYEAR
        , sch."NUMBER" SCHOOL_CODE
        , dis."NUMBER" DISTRICT_CODE
        , per.STUDENTNUMBER
        , prd."NAME"
        , prd.PERIODMINUTES
        , prd.STARTTIME
FROM K12INTEL_STAGING_IC.ATTENDANCE att
    INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal
        ON att.CALENDARID = cal.CALENDARID AND att.STAGE_SOURCE = cal.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.SCHOOL sch
        ON cal.SCHOOLID = sch.SCHOOLID AND cal.STAGE_SOURCE = sch.STAGE_SOURCE AND sch.STAGE_SIS_SCHOOL_YEAR = 2015
    INNER JOIN K12INTEL_STAGING_IC.PERSON per
        ON att.PERSONID = per.PERSONID AND att.STAGE_SOURCE = per.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.PERIOD prd
        ON att.PERIODID = prd.PERIODID AND att.STAGE_SOURCE = prd.STAGE_SOURCE    
    INNER JOIN K12INTEL_STAGING_IC.DISTRICT dis
        ON sch.DISTRICTID = dis.DISTRICTID AND sch.STAGE_SOURCE = dis.STAGE_SOURCE    
WHERE 1 = 1
    and att.presentminutes > 0
    and cal.calendarid = 3411
    and prd."NAME" = '01'
    and per.personid = 250165
--    and per.studentnumber = '8427480'
ORDER BY
    att."DATE"
;
SELECT * FROM K12INTEL_STAGING_IC.TEMP_COURSE_SECTIONS where attendanceid = 231542;
select * from k12intel_staging_ic.calendar where "NAME" LIKE '%Meir%' --calendarid = 3252