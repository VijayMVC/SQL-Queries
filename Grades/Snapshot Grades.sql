SELECT  
        per.STUDENTNUMBER
        , sch."NUMBER" SCHOOL_CODE   
        ,count (distinct crs."NUMBER") courses
        ,ROUND(sum(case when gs.SCORE = 'A' then 4
             when gs.SCORE = 'B' then 3
             when gs.SCORE = 'C' then 2
             when gs.SCORE = 'D' then 1
             else 0 end)/count (distinct crs."NUMBER"),2) as gpa
        ,MAX(case when instr(crs."NUMBER", 'MA211') > 0 then gs.score end) as alg_grade        
 FROM K12INTEL_STAGING_IC.GRADINGSCORE gs
        INNER JOIN K12INTEL_STAGING_IC.GRADINGTASK gt
            ON gs.TASKID = gt.TASKID AND gs.STAGE_SOURCE = gt.STAGE_SOURCE
        INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal
            ON gs.CALENDARID = cal.CALENDARID AND gs.STAGE_SOURCE = cal.STAGE_SOURCE
        LEFT JOIN K12INTEL_STAGING_IC.TERM trm
            ON gs.TERMID = trm.TERMID AND gs.STAGE_SOURCE = trm.STAGE_SOURCE
        INNER JOIN K12INTEL_STAGING_IC.PERSON per
            ON gs.PERSONID = per.PERSONID AND gs.STAGE_SOURCE = per.STAGE_SOURCE
        INNER JOIN K12INTEL_STAGING_IC.SCHOOL sch
            ON cal.SCHOOLID = sch.SCHOOLID AND cal.STAGE_SOURCE = sch.STAGE_SOURCE 
            AND sch.STAGE_SIS_SCHOOL_YEAR = 2015
        INNER JOIN K12INTEL_STAGING_IC.DISTRICT dis
            ON cal.DISTRICTID = dis.DISTRICTID AND cal.STAGE_SOURCE = dis.STAGE_SOURCE
        LEFT JOIN K12INTEL_STAGING_IC.SECTION sec --NOT ALL SECTIONS JOIN OUT?
            ON gs.SECTIONID = sec.SECTIONID AND gs.STAGE_SOURCE = sec.STAGE_SOURCE
        LEFT JOIN K12INTEL_STAGING_IC.GRADINGTASKCREDIT gtc  --CAN CAUSE CARTESIAN?  LAST RECORD WINS FOR NOW.
            ON sec.COURSEID = gtc.COURSEID 
            AND gs.CALENDARID = gtc.CALENDARID 
            AND gs.TASKID = gtc.TASKID 
            AND gs.STAGE_SOURCE = gtc.STAGE_SOURCE
        LEFT JOIN K12INTEL_STAGING_IC.CURRICULUMSTANDARD curr
            ON gt.STANDARDID = curr.STANDARDID AND gt.STAGE_SOURCE = curr.STAGE_SOURCE
        LEFT JOIN k12intel_Staging_ic.course crs
            ON sec.COURSEID = crs.COURSEID AND sec.STAGE_SOURCE = crs.STAGE_SOURCE
 WHERE 1=1
            AND gs.STAGE_DELETEFLAG = 0
--            and per.studentnumber = '8523880'
            and sch."NUMBER" = '0435'
            and instr(gt.NAME, 'Snapshot') > 0
            and trm."NAME" = 'T1'
            AND gs.SCORE IS NOT NULL
            AND NOT EXISTS
            (
                SELECT NULL
                FROM K12INTEL_STAGING_IC.TRANSCRIPTCOURSE tc
                WHERE gs.SCOREID = tc.SCOREID 
                AND gs.STAGE_SOURCE = tc.STAGE_SOURCE
            )
GROUP BY
    per.STUDENTNUMBER
    , sch."NUMBER"