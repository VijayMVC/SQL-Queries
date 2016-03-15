select *
from
(SELECT 
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
        , secp.sectionid
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
        INNER JOIN K12INTEL_STAGING_IC.SECTIONPLACEMENT secp
        ON SECP.PERIODID = prd.periodid and secp.stage_source = prd.stage_source
    INNER JOIN K12INTEL_STAGING_IC.TERM term 
        on secp.TERMID = term.TERMID and att."DATE" between term.STARTDATE and term.ENDDATE and term.STAGE_SOURCE = secp.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.TRIAL tr
        on tr.TRIALID = secp.TRIALID and tr.ACTIVE = 1 and tr.STAGE_SOURCE = secp.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.ROSTER ros
        on ros.SECTIONID = secp.SECTIONID and att.PERSONID = ros.PERSONID and ros.STAGE_SOURCE = att.STAGE_SOURCE and ros.STAGE_DELETEFLAG = 0    
    WHERE 1 = 1
        /*AND EXISTS(select null 
                FROM K12INTEL_STAGING_IC.ENROLLMENT enr
                WHERE att.personID = enr.personID AND att.calendarID = enr.calendarID AND enr.serviceType = 'P' AND att.STAGE_SOURCE =
                    enr.STAGE_SOURCE                
                )*/
        AND cal.EXCLUDE <> 1
        --AND prd.NONINSTRUCTIONAL = 0
        AND att.STAGE_DELETEFLAG = 0
--        and prd."NAME" = '01'
--        and att.attendanceid = 10255564
        AND cal."NAME" = '15-16 NOVA TECH'
        --AND per.STUDENTNUMBER = '523716'
        AND att."DATE" >= TO_DATE('07/01/2015','mm/dd/yyyy')
        AND att.STAGE_SOURCE = 'MPS_IC'
--        AND att.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF
        AND att."DATE" <= sysdate
) v_source_data
INNER JOIN
 ( select att.STAGE_SOURCE, att.ATTENDANCEID, a.sectionid --MIN(a.SECTIONID) SECTIONID
        FROM K12INTEL_STAGING_IC.ATTENDANCE att
        inner join K12INTEL_STAGING_IC.SECTIONPLACEMENT a
        on att.PERIODID = a.PERIODID and att.STAGE_SOURCE = a.STAGE_SOURCE
        inner join K12INTEL_STAGING_IC.ROSTER b
        on a.SECTIONID = b.SECTIONID and att.PERSONID = b.PERSONID and a.STAGE_SOURCE = b.STAGE_SOURCE and b.STAGE_DELETEFLAG = 0
        inner join K12INTEL_STAGING_IC.TERM c
        on a.TERMID = c.TERMID and att."DATE" between c.STARTDATE and c.ENDDATE and a.STAGE_SOURCE = c.STAGE_SOURCE
        inner join K12INTEL_STAGING_IC.TRIAL d
        on a.TRIALID = d.TRIALID and d.ACTIVE = 1 and a.STAGE_SOURCE = d.STAGE_SOURCE
        inner join K12INTEL_STAGING_IC.SECTION e
        on a.SECTIONID = e.SECTIONID and a.STAGE_SOURCE = e.STAGE_SOURCE and e.STAGE_DELETEFLAG = 0
        inner join K12INTEL_STAGING_IC.COURSE f
        on e.COURSEID = f.COURSEID and e.STAGE_SOURCE = f.STAGE_SOURCE
        inner join K12INTEL_STAGING_IC.CALENDAR g
        on f.CALENDARID = g.CALENDARID and f.STAGE_SOURCE = g.STAGE_SOURCE
        inner join K12INTEL_STAGING_IC.PERIOD h
        on att.PERIODID = h.PERIODID /*and h.NONINSTRUCTIONAL = 0*/ and att.STAGE_SOURCE = h.STAGE_SOURCE
        
        where att."DATE" >= TO_DATE('07/01/2015','mm/dd/yyyy')
            and att."DATE" <= sysdate
           -- and att.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF
            and att.STAGE_SOURCE = 'MPS_IC'
 --           and g."NAME" = '15-16 Meir 6-12'
          --  and e.sectionid = 337529
            and g.EXCLUDE <> 1
            and f.ATTENDANCE = 1
            and att."DATE" between coalesce(b.STARTDATE,g.STARTDATE) and coalesce(b.ENDDATE,g.ENDDATE)
            and att.STAGE_DELETEFLAG = 0
     --   group by att.STAGE_SOURCE,att.ATTENDANCEID
       -- having COUNT(*) = 1 
       ) tcs
        on tcs.attendanceid = v_source_data.attendanceid and tcs.sectionid = v_source_data.sectionid
 INNER JOIN
    (SELECT a.COURSE_OFFERINGS_KEY, 
            a.COURSE_KEY,
            a.STAFF_EVOLVE_KEY,
            a.STAFF_ANNUAL_ATTRIBS_KEY,
            a.STAFF_KEY,
            a.STAFF_ASSIGNMENT_KEY,
            a.ROOM_KEY,
            a.course_section_name,
            b.sectionid,
            b.stage_source
    FROM K12INTEL_DW.DTBL_COURSE_OFFERINGS a
    inner join K12INTEL_KEYMAP.KM_CRS_OFFER_IC b on a.COURSE_OFFERINGS_KEY = b.COURSE_OFFERINGS_KEY
    ) co
    on co.SECTIONID = tcs.SECTIONID and co.STAGE_SOURCE = tcs.STAGE_SOURCE 
ORDER BY v_source_data."DATE", TCS.ATTENDANCEID